# DBF D7b: CDX index writes — reader ground truth and rebuild plan

Status: **measured facts + design, not implemented** (2026-11-24). The NTX
half of D7 is landed (hrntx_build + close-time flush, differential gate
tests/dbf/index-write 5/5). CDX writes stay fail-closed ("field write with
an open CDX index is outside this increment (NTX only)") until this plan
lands with its gates. Oracle-measured write semantics for CDX are the
same as NTX (d7_cdx probe: immediate in-file update, seek old fails/seek
new finds in the same session, persists over reopen, multi-letter aliases
only).

## The reader we must satisfy (runtime/hrcdx.c invariants)

Our CDX codec is stricter than the NTX one; any written file must pass
hrcdx_open against the table exactly:

- 512-byte pages. Compound layout: directory page (b[cx32(b)], flags 3,
  one tag entry whose key is the tag name, 10-byte width), tag header
  page (flags 0x60 subset check, key expression at header+512), tree
  pages reachable from cx32(b+header).
- Page flags: depth-0 leaf=1, depth-0 interior=3, deep leaf=0, deep
  interior=2. Leaves at one single depth; sibling links doubly closed
  (left == previous page, right == next page or UINT32_MAX; the walk
  verifies every level's chain end to end).
- Leaf entries: 24-byte header (n, free, mask, dm/tm/rb/db/tb/bytes with
  rb+db+tb==8*bytes and dm/tm >= width), then n entries of `bytes` bits
  packed at 24+i*bytes (rec = low rb bits, dup = next db bits, trail =
  next tb bits), key bytes stored BACKWARD from the page end (end starts
  512, each key consumes width-dup-trail bytes), free == end-(24+n*bytes)
  EXACTLY. First entry must have dup=0. rb=32 (rec mask 2^32-1) fits
  bytes=6 with db=tb=8, and dup=0/trail=0 is legal per entry, so a
  REBUILD may store every key uncompressed (n=width bytes each).
- Interior entries: {key(width), rec(4), child(4)} big-endian at
  12+i*(width+8), and the entry MUST EQUAL the last entry of its child
  subtree (the CDX separator duplicates a real leaf entry - unlike NTX,
  where the separator lives only in the interior page).
- Non-structural single-tag bags only (dir with exactly one tag), key =
  the bare C field (field lookup by name, type 'C', width == cx16(header+12)).

## Rebuild plan (same shape as the landed NTX half)

1. `hrcdx_build` in runtime/hrcdx.c: copy the directory page and the tag
   header page (+ its key-expression page at header+512) from the current
   image, emit fresh leaves (uncompressed keys, chunked to the capacity
   n <= (488-width... actually n*width + n*6 + 24 <= 512, i.e.
   n <= (488)/(width+6)) and a single interior level when more than one
   leaf (interior entry = last entry of its child subtree, big-endian),
   patch the root pointer in the copied header page, and set every
   sibling link. Two-level bound like NTX: leaves <= interior capacity.
2. Reuse the NTX plumbing already landed: hrntx_file_rebuild gains a
   CDX branch calling hrcdx_build + hrcdx_open validation + the same
   cursor re-park; the flush path is identical (512-granular image).
3. The write-site changes in hrdbf_app.c are already staged behind
   hrdbf_app_cdx: lifting the rejection switches the maintenance path on.
4. Gates: extend tests/dbf/index-write with CDX differential programs
   (the fixture builder already produces ixw_cdx.dbf + ixw_tag.cdx) and
   flip r01 from a named-rejection row to a differential row.
5. Risks recorded: the oracle balances the last two leaves; our fixed
   chunking differs but is reader-valid (same as NTX, cross-reader
   oracle reads still unverified); multi-tag bags and non-C key
   expressions stay out (reader subset unchanged).

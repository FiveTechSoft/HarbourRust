# DBF D7: index updates on write — measured oracle facts and scope proposal

Status: **oracle-measured facts (2026-11-24, native Windows 11, Harbour 3.2
mingw64 -gtcgi), design proposal, not implemented**. Probes
d7_ntx2/d7_ntx3/d7_ro/d7_cdx (Temp session copies of the
tests/dbf/goto-setorder and mk_fixture builders). No index-write path is
wired by this document; hbc's native adapter keeps its fail-closed
"field write with an open index is outside this increment" rejection
until the admitted subset below lands with its gates.

## What the oracle does (measured, both NTX non-structural and CDX structural)

- **Immediate in-place update.** With the order selected, `FieldPut` of an
  indexed key updates the index IMMEDIATELY: `dbSeek(old)` fails and
  `dbSeek(new)` finds the record in the SAME session (d7_ntx2: seek-old
  .F. with RecNo parked at LastRec()+1; seek-new .T. with the record).
- **The index file changes, not just memory.** After `dbCloseArea` +
  reopen, the new key is found and the old key is gone (both drivers).
- **`dbAppend` + key write enters the order immediately** (d7_ntx2
  seek-appended, and it persists over reopen; `dbGoTop` in the order
  returns the smallest key, appended keys sort by value).
- **`dbDelete` does NOT touch the index.** The deleted record's entry
  stays and `dbSeek` still finds it (d7_ntx3; persists over reopen with
  `Deleted()` .T.). Filtering deleted records from order traversal is a
  SET DELETED concern, not an index-write concern.
- **Readonly open + write** (index open or not): the oracle raises
  DBFNTX/1025 "Write not allowed" (d7_ro). hbc's existing named
  runtime rejection already covers this case.
- Alias note (twice observed now): single-letter aliases are unreliable
  in the oracle's dbCloseArea/reopen cycle around writes ("D" and "G"
  both produced DBCMD/1011 "Alias already in use" where "T"/"X"/"GS"
  reopen fine). Probes use multi-letter aliases.

## Scope proposed for the hbc native adapter

Single workarea, single selected order, one admit-what-exists
increment:

1. **Key-space maintenance on the selected order only**: a FieldPut /
   REPLACE / ALIAS->field := / dbAppend key change rewrites the index
   file in place (insert/remove of one key in the existing b-tree page
   structure the readers already parse). Deleted records keep their
   entries (oracle-measured).
2. **Commit contract**: same immediate-commit style as the D2 field
   writes (pwrite64 on the .ntx/.cdx bytes, then the record write). No
   extra flush point.
3. **dbDelete/dbRecall stay index-neutral** (measured).
4. **Error modes**: unchanged named rejections for readonly; a
   key-expression that cannot be evaluated from the new record value
   fails fast naming the expression, never a silent wrong index.
5. **Out of scope (later)**: multiple open orders (the oracle maintains
   every open order; hbc would start with one), shared opens (D8),
   ordCreate codegen, index REINDEX/pack, macho targets.

## Why not implemented in this session

The write side needs b-tree page surgery in runtime/hrntx.c (NTX:
512-byte pages, ascending key b-tree) and runtime/hrcdx.c (CDX leaf
pages) that today only read. That is the OpenADS-scale core of D7; the
measured facts above bound it (one key in, one key out, one order) but
the page split/merge rules must come from the format, not guesses, and
every one of them is verifiable against the oracle with the same
differential pattern as D2-D6 before publication.

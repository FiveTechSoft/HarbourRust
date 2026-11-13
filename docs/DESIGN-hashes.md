> Historical probe note (2026-11-13): `archived-probe:` and `historical-probe:` identify evidence from earlier revisions, not current checkout paths. The extra probe directory was removed at the owner's request; the regression manifest and oracle corpus remain. Its last full snapshot is in commit `595ecd87b214068047844acbf430f0da817deeb7`.

# Hashes v1 - design notes (IMPLEMENTED as t231-t244, 2026-10-25)

Oracles (compiled hbmk2 -gtstd, historical-probe:hashes, re-run 2026-10-25):
- h1: insertion order preserved; overwrite in place (len stays 2;
  hb_HKeys = [a, b]; h["a"] = 9 after rewrite).
- h2: {=>} empty, len 0.
- h3/h3c: missing-key read (incl. different case "a" vs "A") = Harbour
  Error BASE/1132 Bound error, interactive dialog, HANGS headless
  (exit 124) -> our registered failure-mode: clean message + exit 1.
- h3b: string keys are CASE-SENSITIVE (h["A"] = 1).
- h4: h[k] := v evaluates the VALUE before the KEY (prints 7 then b).
- h5: variable string keys work (h[k]:=5, h["z"]=5, len 2).
- h6: hb_HKeys returns an array of keys (len 1). OUT of v1.
- h7/h7b: Harbour allows hash/array self-reference cycles (retained);
  our model: compile error (ownership), same as arrays.

Oracles run for v1 semantics (historical-probe:hashes2, hbmk2 -gtstd):
- h8: duplicate keys in one literal -> len 1, last value wins
  (overwrite in place).
- h9: inside a literal each pair evaluates its KEY first, then its
  value (K1, V1, K2, V2) - the OPPOSITE of `h[k] := v` (h4).
- h10: the empty string is an ordinary key (len 1, h[""] hits).
- h11: keys with an embedded NUL (via chr(0)) work; Harbour compares
  byte strings with length, not C strings.
- h12: prefix keys stay distinct ("a" vs "ab": len 2, both hit).
- h13: case variants are distinct keys ("Ab" vs "a" family of h3b).

Already in tree: lexer FatArrow, parser HashLit ({k => v, ...} and
{=>}); type_expr rejects with "next increment" (line ~1422); cg arms
unreachable (lines ~2108, ~2381); free_vars handles HashLit.

## Representation (mirrors DArr)
- Ty::Hash; stack local 16 bytes {ptr, len} (ptr at -off, len at
  -(off-8)), null/0 = empty. size_of(Hash) = 16.
- Heap block via hbc_alloc: 8-byte capacity header (in PAIRS) at
  base, then 32-byte entries: {keyptr, keylen, tag, payload}.
  keyptr -> key bytes copy allocated 8+keylen (len at its base, so
  hbc_free(keyptr, 1) works: 8 + len*1). Values are Dyn {tag,
  payload}: i64 or NIL in v1.
- Free: new helper hbc_hfree(rdi=blockptr): loop cap entries... no:
  loop LIVE len entries? Entries are packed [0..len); capacity in
  header for growth. Free each entry key (hbc_free keyptr, 1), then
  hbc_free(blockptr, 32). Key copies move with the block on grow;
  old block freed shallow (hbc_free old, 32) after copy, keys
  survive in the new block.

## Helpers (BOTH targets, internal ABI rdi/rsi/rdx/rcx)
- hbc_hget(rdi=&local, rsi=keyptr, rdx=keylen) -> rax = &entry.tag
  or 0. Byte-compare loop, case-sensitive.
- hbc_hput(rdi=&local, rsi=keyptr, rdx=keylen, rcx=&value16):
  found -> overwrite entry {tag,payload}, done. Miss -> grow like
  hbc_aadd (newcap = cap ? cap*2 : 4, overflow -> hbc_oom), copy
  entries, copy key bytes (own alloc), append, free old block
  shallow, update local {ptr,len}.
- hbc_hfree(rdi=blockptr non-null, rsi=len): as above.
- Epilogue/re-declare/reassign: Hash slots join darr_slots with a
  third class (or a flag) -> call hbc_hfree instead of hbc_free.

## Typing / semantics (v1)
- HashLit: keys Str, values I64 or Dyn (NIL ok). Ty::Hash.
- h["k"] read (Expr::Index on Hash): key Str; cg: eval key, hget,
  0 -> hbc_bound_error; else load Dyn pair. Returns Ty::Dyn.
- h[k] := v (Stmt::ArrSet on Hash): VALUE first, push {tag,payload}
  (I64 tagged {0,v}); then KEY; call hbc_hput.
- len(h) -> pair count (local len word).
- Whole-hash print rejected in analysis (like arrays).
- Assign h2 := h1 MOVES; source nulled; use-after-move = compile
  error (join the Str|DArr moved-machinery at lines ~1225, ~2001
  and the nulling at ~2617).
- Keys: any Str expr (literal or variable); hput copies the bytes,
  so rodata literals are safe. Current strings may all be static;
  no general heap-string lifetime is claimed here.
- hb_HKeys, non-string keys, hash values that are arrays/hashes:
  NOT v1. Cycles impossible by construction (no hash-in-hash).

## Tests (implemented: t231-t244; the registry harness owns t224-t230)
t231 literal+read+len (h1 shape), t232 dup keys in one literal (h8),
t233 {=>} len 0, t234 missing key -> posx bound error, t235 case
sensitivity (miss -> bound error), t236 `h[k] := v` value-before-key
(h4), t237 literal key-before-value (h9), t238 empty key (h10), t239
prefix keys (h12), t240 NIL value roundtrip, t241 move semantics
(use-after-move neg), t242 memcheck balance across a function
boundary, t243 grow past the initial capacity, t244 overwrite keeps
the pair count (h1 shape).

NOT asserted: insertion order. Reading both keys does not prove
order; without hb_HKeys or iteration there is no observable order in
v1, so no battery test claims it (order is preserved internally by
construction only). hb_HKeys is the next-scope candidate that would
make order observable.

## Corrections applied before implementation (parent, 2026-10-25)
- Tests are t231+ (registry harness owns t224-t230).
- Reading both keys does not prove insertion order (see Tests).
- Literal key/value order and items have their own oracles
  (h8-h13), not inferred from `h[k] := v`.
- hput copies the key bytes into an owned allocation BEFORE any
  grow, so an allocation failure leaves the hash and the caller's
  temporaries untouched; a lookup miss never mutates the hash; grow
  frees the old block shallow (the key copies moved with the
  entries); hfree uses the LIVE length, never the capacity.
- The &value16 temporary and the key bytes stay caller-owned across
  hput (hput copies both).

## Also queued in D3/D4 (parent 2:07:15)
- Array(n) and Array(n, m) constructors vs oracles m3/m10/m11:
  Array(n) = ASize({}, n) equivalent; Array(n,m) = n NIL... no:
  m11 shows growing a 2-D parent adds NIL slots, but Array(2,3)
  CREATES full children. Constructor must allocate children. Slots
  in a grown DArr2 parent are empty children (t186) while Harbour
  makes them NIL - registered difference; Array(n,m) needs
  Dyn-tagged parent slots to match Harbour exactly. Decide: either
  accept the registered difference (Array(n,m) builds full children,
  grow still yields empty children) or widen DArr2 parents to Dyn2.
  Table row Array(2,3) updated in source (not yet republished).

## Hard-won asm rules (from the registry harness, 2026-10-25)
- hbc_free callers keep loop state in r9/r10 (hbc_asize shrink) and
  possibly rdx: any new helper must preserve them or document its
  clobbers at the comment header. rcx/r11 are always dead across a
  syscall; kernel32 calls kill rcx/rdx/r8-r11 by ABI.
- Indexed access to data symbols MUST go through lea sym(%rip), reg
  first: absolute 32-bit indexed addressing does not link for Win64
  (R_X86_64_32S against .bss).
- hb_memcheck() inside main reads BEFORE main's own epilogue frees:
  balance tests must do the allocating work in a callee (t225/t226
  failed on this, not on real leaks).
- The allocation registry (t224-t228) verifies exact free size and
  liveness; new alloc'd structures (hash blocks, key copies) get the
  check for free. Double free of a key copy or a hash block = harness
  error, which is exactly what we want.
- Numeric asm labels 30-49 are free (runtime uses 1-9, 51-79, 90-98;
  cg-inline uses 83-89 and 91x).

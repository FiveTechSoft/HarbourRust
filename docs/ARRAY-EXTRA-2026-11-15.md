# AClone, ATail and ASort for flat dynamic arrays

Base: 6920e98. This increment adds three array builtins on the same
admitted shapes as AScan: a flat dynamic integer array (`Array(n)` plus
element writes or `AAdd`) or a flat dynamic string array (an all-string
literal). Static array literals, nested arrays, hashes and Dyn-casilla
arrays are named rejections.

## Admitted semantics

- `AClone(a)` returns a NEW flat array with copied cells. Integer cells
  copy as-is; string cells are copied into fresh owned buffers, so
  mutating the clone never affects the source. The return type follows
  the source type (`DArr` or `DArrS`).
- `ATail(a)` returns the last element: an integer/NIL pair for integer
  arrays, an owned string copy (tag 4) for string arrays, and NIL for an
  empty array.
- `ASort(a [, start [, count]])` sorts the selected 1-based range in
  place, ascending. Integers compare numerically; strings compare
  byte-wise with the existing Dyn comparison helper. `start < 1`
  clamps to 1; a non-positive or oversized count sorts to the end. The
  call answers NIL; Harbour's returned array value is outside this
  statement surface.

## Runtime and ownership

The clone helpers allocate through `hbc_aclone_alloc`, an alias that
jumps to `hbc_valloc` when the VAS flat-array runtime is active and to
`hbc_alloc` otherwise, so the block layout matches the free path the
emitter uses (`hbc_vfree` / `hbc_free`). ASort and ATail never allocate
array blocks; string results use `hbc_strcpy` and the normal owned-string
free path.

## Verified

Real Windows PE, normal and instrumented: clone independence for integer
and string arrays (source unchanged after clone mutation), ATail on
integer/string/empty arrays, ASort full and ranged integer sorts and
string sorts. Negative cases: static literals and nested arrays reject
with the named checker messages above. A 42-case manifest sample and the
three new manifest fixtures (t1679-t1681 range) pass.

## Limits

No nested/static/Dyn arrays, no descending or codeblock comparator, no
case-insensitive string order, no mixed-type ordering. ASort on an array
holding NIL or mixed families raises the registered Dyn comparison
failure mode. This is not full Harbour ASort semantics and carries no
throughput claim.

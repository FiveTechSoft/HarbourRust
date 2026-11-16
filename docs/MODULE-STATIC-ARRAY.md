# Module STATIC S3: persistent fixed i64 arrays

Base: 188c4844 (S2 final). The S1 i64 route and the S2 logical/owned-string
route stay intact; this document owns the new fixed-array boundary.

## Representation and lifetime

A module STATIC may now be initialized with a flat, non-empty array literal
of folded i64 constants: `STATIC a := {1,-2,30}`. The array has a fixed
arity for the life of the process. Cells are emitted as N eight-byte
constants in .data next to the other module slots: there is no init hook,
no owner and no cleanup, so the final memory balance stays trivially zero
for this storage class.

Every function that mentions the name and does not shadow it binds to one
canonical shared label (module_static::storage). Cell reads and writes go
through that absolute label instead of a frame slot, so a write in one
function is visible to every other function on its next read: the alias
semantics Harbour gives module arrays. The local binding carries the fixed
arity (Ty::Arr(n)) so len() lowers to the arity constant and the existing
1..=n bounds checks apply unchanged.

Cell assignment keeps the established evaluation order: the value is
evaluated first, then the index; a[i] := a[j] is a pure i64 copy.

## Named limits

- Fixed i64 cells only. Nested, mixed, empty, float, Date, NIL, logical,
  string or hash initializers fail at declaration; nested arrays would make
  reference cycles possible, which this storage class deliberately excludes.
- Whole-array values stay out: `LOCAL b := a`, `? a`, passing `a` to a call,
  `a := {...}`, containers mentioning `a`, code blocks and sends. Harbour
  aliases arrays on assignment while this compiler's frame-resident fixed
  arrays copy; admitting any whole-array route would bake in that
  divergence. The guard rejects them by name.
- Multi-level indexing (a[i][j] and spellings a[i,j]), compound cell ops
  (a[i] += v), @a borrows and the structural ops AAdd/AIns/ADel/ASize/AFill
  are rejected in this increment.
- The guard's expression classifier is exhaustive over expression forms
  with no wildcard (same rule as the S2 repair): a future form stops the
  build until classified. Statements keep the lexical-mention fallback
  accepted for the owned-string guard. Exhaustiveness is not a proof of
  safety for every expression semantics.
- Shadowing, MEMVAR overlap, branch/catch shadows and loop-counter limits
  are unchanged from S1/S2.

## Oracle dialect and test provenance

All tests are synthetic, with no Harbour implementation or
external-contribution source copied. The same .prg source is supplied to
both compilers: fresh Harbour GTSTD (pin 694428e1) on Linux and PE-Wine,
exact stdout/stderr/exit compared byte-for-byte. The S1 runner loses its
`array` negative (now supported) and its initializer diagnostic text is
updated; the new tests/module-static-array/ runner owns this increment's
probes and negatives.

## Gates on the final compiler

SHA256: bd8232b866f36a70efc91150e72be9bd4f703d2de6d9e652f37247b8a9ad018a.
- S3: 7 positive sources x two targets = 14 exact oracle comparisons
  (initializer order, persistence across calls, two-function aliasing,
  computed/nested indexes, cell-by-value calls, statement sequencing,
  mixed i64+string+array slots); 13 Harbour-valid negatives x two = 26
  named rejections (nested/mixed/empty initializers, alias, whole print,
  call argument, @ borrow, multi-level index, AAdd, AFill, compound cell
  op, container, whole assignment).
- Regression on the same compiler: S1 56/56 (its array negative removed as
  now supported), S2 owned 74/74, S2 memory 34/34 with the final zero
  assertion on both targets, FILE 56/56, classes 42/42, PE separators 3/3,
  names/Date 38/38, units 57/57, compile-PE CI 1802 PASS + 21 known
  mismatches + 0 FAIL. The CI manifest loses the deleted array negative,
  tracks the new initializer diagnostic text, and gains the 20 S3 rows.

# Dynamic arrays / hashes: ownership and heap design (pre-implementation)

Grounded in compiled Harbour oracles (probes d1-d12, e1-e9; sanitized
sources promoted to `probes/`). This document fixes the model BEFORE any
heap code is written.

## What Harbour actually does (probe evidence)

- Arrays and hashes are REFERENCE values. `b := a` aliases (d8, d6);
  `b := a[1]` extracts a nested array by reference (d7); passing an
  array to a function aliases it too - a callee's `AAdd` mutates the
  caller's array (e9).
- `AAdd(a, x)` grows by one and RETURNS THE ADDED VALUE, not the array
  (e5: `b := AAdd(a,5)` leaves `b == 5`).
- `ASize(a, n)` resizes in place; grown slots are NIL (e1), shrinking
  keeps surviving elements (e2). `len({})` is 0 (e4).
- Nested dynamic arrays work (e7). Mixed-type arrays work (e6).
- Reading a missing hash key or an out-of-range index aborts with an
  interactive dialog that hangs headless (d11, a2 family).

## Our model (explicit Rust ownership, no GC, no refcount, no shared alias)

Every dynamic value has exactly ONE owner at every program point.
Assignment and argument passing MOVE (the source becomes Moved and
frees nothing; the destination owns exactly one freeing). Harbour's
sharing patterns (d6-d8, e9) are registered MODEL divergences: they
fail to compile as use-after-move, and the Harbour idiom must be
rewritten explicitly (e.g. return the array from the helper).

### Ownership states per local (physical, no static path tracking)

- The ownership state is PHYSICAL: every dynamic-array slot starts as
  (null, 0); a move nulls the source slot. Freeing is null-safe, so
  the compiler needs no per-path Owned/Moved analysis: freeing every
  slot at the function epilogue is correct on every path.
- Joins/branches: a slot holds its value or null; both are freeable
  exactly once. Untaken branches are safe because slots are zero-init.
- Loops: a local re-declared in a later iteration frees its previous
  value when the new binding overwrites the slot; anything still owned
  at function end is freed at the epilogue. No loop-back-edge freeing.
- Harbour `exit` leaves the LOOP, not the function: it frees nothing;
  locals declared outside the loop stay usable after it (t170).
- Self-referential assignment (`a := <expr using a>`): the RHS is
  evaluated FIRST; the OLD value is freed only after the RHS has been
  fully evaluated (value-first order, same rule as indexed assignment).
- Move NEVER frees. Free happens exactly once, at the owner's end:
  reassignment (old value, after RHS), scope exit, function exit paths.

### Heap layout (first heap in the compiler; strings stay static)

- Linux: `mmap`/`munmap` syscalls; an mmap FAILURE is a negative errno
  value, not only NULL, and is checked as such. Windows:
  `GetProcessHeap` + `HeapAlloc`/`HeapFree` (no HeapReAlloc: see growth).
- munmap needs the ALLOCATION length: it is recomputed from the
  capacity header (8 + cap*8 bytes), so the header must be intact.
- Dynamic array value: 16 bytes `(data_ptr, len)`; capacity stored in
  an 8-byte header at `data_ptr - 8`. Element size fixed at the
  element type's size in this increment (i64: 8 bytes).
- Growth: `AAdd` doubles capacity when `len == cap` (0 -> 4 elements),
  on BOTH targets by allocate + copy + free-old: the slot is replaced
  only after the new block is fully populated, so a failed allocation
  never loses the old block or leaves the slot dangling.
- Overflow/OOM: `cap * elemsize + header` computed with checked
  arithmetic; on overflow or allocation failure the process prints a
  runtime error message and exits non-zero (no silent wraparound).
- Grown slots (`ASize` grow, fresh capacity) are ZERO-FILLED.
  DOCUMENTED MODEL DIFFERENCE: Harbour fills with NIL (e1); our arrays
  are i64-only in this increment and NIL has no i64 analogue, so grown
  elements read as 0. Not declared equivalent.
- Nested/multidimensional dynamic arrays: NOT in this increment
  (elements are i64 only). When added, the parent owns its element
  arrays and frees them recursively; move semantics keep reference
  cycles inexpressible.

### Surface syntax

- `AAdd(a, x)` and `ASize(a, n)` are BUILT-IN STATEMENTS (not ordinary
  calls): they mutate the named local in place, the only way to mutate
  through our no-alias model. `len(a)` is a built-in expression.
- Dynamic arrays passed to user functions MOVE (like strings). The
  Harbour param-aliasing idiom (e9) is a registered MODEL divergence.
- Hashes: NOT in this increment (oracles captured). They will follow
  the same ownership rules; key order = insertion order (d12);
  missing key read = clean runtime error + non-zero exit
  (DIVERGE-FAILMODE vs Harbour's hang, d11).

### Proof obligations before publishing dynamic arrays

1. Alloc/free balance: a debug build with allocation counters must
   report balance 0 across a dedicated harness exercising: plain
   scope, branch join (moved in one arm), loops, early return, exit
   statement, self-referential reassignment, nested arrays, AAdd
   growth, ASize shrink/grow. Linux AND Wine.
2. No claim of general memory safety, no GC/refcount, no Rust-safety
   claims beyond what the harness shows.
3. Every divergent Harbour pattern (d6-d9, e5, e9, d11) has a
   permanent battery test pinning OUR chosen behaviour.

# Module STATIC S4: dynamic/nested arrays with shared heap references

Status: implemented and verified. Base a77bdd22 (post-ARM64); review-fix
commits through 84835379. Oracle pin Harbour 694428e1, Linux GTSTD and
Windows cross; every positive claim below is byte-exact against a fresh
oracle run, and every rejection is a named compile-time or runtime
diagnostic (probes p1-p25, review probes pA-pI in the evidence bundle;
suites ms/msa/owned/owned-mem/classes/file-compat/ci re-run green on the
final compiler).

This document supersedes the S3 model for module STATIC arrays: S4
SUBSUMES S3. Harbour has one array semantics (every array is dynamic);
keeping a flat-i64 fixed route beside the dynamic one would fork behavior
by cell content and diverge on AAdd/ASize of flat arrays. S3's positive
programs remain byte-exact; the S3 negatives split into admitted (moved
to the msa positive suite) and still-rejected (named, below).

## What Harbour actually does (fresh probe evidence, 2026-11-16)

- Nested/mixed initializers work: STATIC a := {1,"x",{2,3}}; a[3][1]
  multi-level reads (p1). len() reports arity per level.
- Whole-array assignment ALIASES: LOCAL b := a; b[1] := 99; ? a[1] prints
  99 (p2). Extracting a sub-array aliases it too: LOCAL b := a[2] (p11).
  Passing a module array to a function aliases it (p6).
- AAdd grows by one; nested arrays and mixed types as values (p3). Empty
  {} is a valid initializer; AAdd grows it, including AAdd(a, a) (p10).
- CYCLES work: AAdd(a, a) then a[2] IS a; mutating a[1] shows through
  a[2][1] (p4). Reassigning the module name drops the old object; cyclic
  garbage is freed at exit (p13).
- Cross-function cell mutation through nesting (p5). Reassignment to a
  new literal of different shape/type works (p8).
- AIns/ADel/ASize shift/resize (q_ains/q_adel/q_asize).
- `? a` prints an array as EMPTY (p7/p9 raw bytes). ValType(a) is "A".

## Model (Harbour-following: shared references, registry, exit sweep)

The task instruction settles copy-vs-alias: follow Harbour (alias).
Module STATIC dynamic arrays are the first storage class in this
compiler with Harbour reference semantics; function-local dynamic arrays
keep their single-owner move model unchanged.

- Array OBJECT: 32-byte heap header {len@0, cap@8, registry_next@16,
  cells@24} + a separate 16-byte-stride cell buffer {tag, payload}.
  Cells are separate so AAdd/ASize growth never moves the object
  identity that aliases and cycles point at.
- Cell tags admitted in a shared array: 0 i64, 1 NIL, 3 logical,
  4 owned string, 16 shared array reference. Tag 16 payload = child
  OBJECT base; one tag for roots, cells, locals, params and returns.
  Floats (tag 5), hashes and codeblocks are NOT admitted (named
  rejections); the Dyn-boundary runtime family check {0,1,3,4,16} at
  AAdd and ArrSet turns any Dyn-carried foreign tag into hbc_type_error.
- REGISTRY: every object created through a module-static array route is
  linked into a global intrusive list at creation. No refcounting.
- CYCLES BY CONSTRUCTION: the exit sweep needs no mark phase: phase 1
  releases each object's owned string payloads (never recursing into
  array cells), phase 2 frees all objects. A cycle is ordinary memory,
  freed exactly once; the S2 memory hook's final zero balance covers
  this storage class. No mid-run collection: objects orphaned by
  reassignment stay allocated until process exit (named limit;
  invisible in stdout bytes).
- The module slot is one canonical 16-byte Dyn casilla {tag 16, object
  pointer} in .data, initialized once before INIT hooks and shared by
  every function. Every read/write of the module name goes through the
  canonical .data label: a whole-literal rebuild inside a callee is
  visible in every frame (p17, review probe pA). LOCAL b := a takes a
  value copy of the reference (Harbour rebind semantics).
- REBUILD: `a := {..}` with a constant literal (nested admitted)
  materializes a fresh registered object and replaces the canonical
  reference; a non-constant literal is rejected (assign_nonconst).
- ALIASES: LOCAL b := a, LOCAL b := a[i], Dyn-typed by-value parameters
  and RETURN of the array all carry the same non-owning tag-16 pair;
  tag-16 release is a no-op and tag-16 clone copies the pointer, so the
  epilogue and the move checker need no new local variant. Writes
  through any alias hit the one object (review probes pB/pE family).

## Admitted (verified byte-exact vs oracle)

- Constant initializers: i64/logical/string/NIL cells, nested constant
  literals, empty {}.
- Cell reads and writes at any depth; index expressions; len() at any
  level (incl. len(a[i]) through the canonical root); ValType ("A" for
  arrays, per-content for cells); HB_IS*; `? a` (empty).
- AAdd with scalar values and with the array itself (cycles); ASize
  grow (NIL fill) and shrink (dropped owned payloads released).
- Whole-array rebuild from a constant literal, in any function.
- Alias locals at any level; Dyn-typed parameters and returns carrying
  the reference; cell-by-value scalar arguments.
- Overflow safety: ASize and the AAdd doubling check the representable
  maximum (2^59 cells) BEFORE multiplying and raise hbc_oom; probe pH
  (ASize 2^60) exits with a clean "Out of memory" where the Harbour
  oracle segfaults.

## Named rejections (guard, exhaustive, no wildcard)

Compile time, each with its own diagnostic text:
- module STATIC array storage with threads (pC1/pC2).
- Non-constant rebuild literals (assign_nonconst).
- Float/date/hash/NIL-of-wrong-class initializer cells; float values at
  the Dyn boundary (runtime hbc_type_error instead).
- Whole-array value uses: compare/arithmetic/logic operands, IF/WHILE
  conditions (cmp_whole/if_whole).
- AIns/ADel/AFill, literal AAdd values (aadd_lit), @ borrows of the
  array or its cells, compound cell ops (a[i] +=), container captures,
  blocks/Eval capturing the array, ACopy/AEval/AScan/ASort and every
  unmeasured whole-array builtin (one shared diagnostic family).
- Storing an object cell / a single-owner LOCAL dynamic array into a
  shared cell (obj_cell).
- Passing the array to a TYPED array parameter (E diagnostic; typed
  array parameters on shared arrays are deferred). Dyn-typed parameters
  are admitted and alias (pE10).

## Registered divergences

- Out-of-range reads exit via hbc_bound_error; Harbour opens a dialog.
- Orphaned objects live until the exit sweep (no mid-run GC).

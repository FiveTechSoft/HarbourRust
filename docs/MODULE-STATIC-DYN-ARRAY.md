# Module STATIC S4: dynamic/nested arrays with shared heap references

Base: 095aee9c (post-ARM64). Implemented and verified (probes p1-p25,
suites ms/msa linux+windows, units). Grounded in fresh Harbour oracles (probes below,
pin 694428e1, Linux GTSTD; the gate will re-verify both targets byte-exact).
This document fixes the model BEFORE any heap code is written, in the style
of DESIGN-dynamic-ownership.md. S1-S3 routes stay intact: fixed i64 arrays
keep their flat .data storage; this document owns the new shared-reference
boundary.

## What Harbour actually does (fresh probe evidence, 2026-11-16)

- Nested/mixed initializers work: STATIC a := {1,"x",{2,3}}; a[3][1]
  multi-level reads (p1). len() reports arity per level.
- Whole-array assignment ALIASES: LOCAL b := a; b[1] := 99; ? a[1] prints
  99 (p2). Extracting a sub-array aliases it too: LOCAL b := a[2] aliases
  the nested array (p11). Passing a module array to a function aliases it:
  the callee's writes and its return value share the one object (p6).
- AAdd grows by one; nested arrays and mixed types as values (p3). Empty
  {} is a valid initializer; AAdd grows it, including AAdd(a, a) (p10).
- CYCLES work: AAdd(a, a) then a[2] IS a; a[2][1] reads a[1]; mutating
  a[1] shows through a[2][1] (p4). Reassigning the module name drops the
  old object; cyclic garbage is collected silently (p13: a := {9} after a
  cycle; later reads see only the new object).
- Cross-function cell mutation through nesting (p5). Reassignment to a new
  literal of different shape/type works (p8).
- AIns(a, i) shifts right WITHIN the current size (tail falls off, NIL at
  i); ADel(a, i) shifts left (NIL at tail); ASize(a, n) resizes, grown
  cells NIL (q_ains/q_adel/q_asize).
- `? a` and `? a[3]` print an array as EMPTY (p7/p9 raw bytes: no text,
  just the item separator/newline). valtype(a) is "A", valtype of cells
  per content (p9).

## Model (Harbour-following: shared references, registry, exit sweep)

The task instruction settles the copy-vs-alias choice: follow Harbour
(alias). Module STATIC dynamic arrays are therefore the first storage
class in this compiler with Harbour reference semantics; function-local
dynamic arrays keep their existing single-owner move model and its
registered divergences, unchanged.

- Array OBJECT: heap header {len, cap, registry link} + 16-byte tagged
  cells (existing Dyn cell layout: nil / i64 / f64 / owned string /
  array pointer). A cell's array pointer is a non-owning shared
  reference; only string payloads are owned per object.
- REGISTRY: every array object created through a module-static array
  route (module initializer, whole-array reassignment, array literal
  stored into a shared cell) is linked into a global intrusive list at
  creation. No refcounting anywhere.
- CYCLES BY CONSTRUCTION: because the registry holds every object, the
  exit path needs no mark phase: phase 1 releases each object's owned
  string payloads (never recursing into array cells), phase 2 frees all
  objects. A cycle is then ordinary memory, freed exactly once, and the
  final memory balance is zero. There is no mid-run collection: objects
  orphaned by reassignment stay allocated until process exit (named
  limit; invisible in stdout bytes, which is what the oracle compares).
- The module slot is one canonical 16-byte Dyn casilla {tag 16,
  object pointer} in .data, zeroed, initialized once before INIT hooks
  and shared by every binding function. The canonical casilla is the
  ONLY variable: every read/write of the module name goes through the
  .data label, so a whole-literal rebuild inside a callee is visible
  in every frame (probe p17). Local aliases (`LOCAL b := a`) take a
  value copy of the reference, Harbour rebind semantics.
- REBUILD: `a := {..}` with a constant literal materializes a fresh
  registered object and replaces the canonical reference; a non-
  constant literal is rejected (registered limit; assign_nonconst).
- Whole-array VALUE uses are rejected (registered limits): direct Var
  as compare/arithmetic/logic operand or IF/WHILE/FOR EACH condition
  (cmp_whole/if_whole), object cells (obj_cell), literal AAdd values
  (aadd_lit), @ borrows, compound cell ops, AIns/ADel/AFill.
- ALIAS HANDLES: inside a function the name binds as a non-owning handle
  loaded from the canonical slot. `LOCAL b := a`, `LOCAL b := a[i]`
  (array cell), by-value parameters and returned arrays all produce the
  same non-owning handle type. Handles are exempt from the epilogue
  release and from the move checker; writing the handle's cells writes
  through to the shared object. Assigning to an alias handle rebinds
  the handle; assigning to the module NAME replaces the canonical
  slot's pointer (old object becomes registry garbage).
- Structural ops (AAdd/ASize/AIns/ADel/AFill) on the module array or any
  alias mutate the shared object in place, matching the probed Harbour
  semantics above.

## Guard shape (exhaustive, no wildcard, as S2/S3)

Admission list for a module dynamic array name: nested constant
initializer (i64/f64/logical/string/NIL/empty or nested arrays); cell
reads at any level; cell writes at any level (ArrSet family); AAdd/
ASize/AIns/ADel/AFill on it; alias-producing locals, by-value params and
returns; whole-array reassignment from a literal; len()/valtype();
`? name` (empty output); cell-by-value scalar arguments. Rejections by
name: threads, @ borrows of the array or its cells, hashes as values,
blocks/Eval capturing it, ACopy/AEval/AScan/ASort and every unmeasured
whole-array builtin, sending it as a message receiver, storing a
single-owner LOCAL dynamic array into a shared cell (owner classes must
not mix).

## Integration with existing machinery (mapped 2026-11-16)

- hbc_module_strings_init / hbc_persistent_cleanup are the models: S4 adds
  hbc_module_arrays_init (called from _start before INIT hooks, deduplicated
  per canonical label) and an array sweep inside hbc_persistent_cleanup, so
  the S2 memory hook's final zero assertion covers this storage class.
- Existing array types are NOT reusable as-is: Ty::Arr is stack-fixed;
  DArr2/3/4 are fixed-DEPTH trees (child casilla {ptr,len}) with
  single-owner roots; DArrDyn (tag-8 Dyn-held) rejects tag-6 array cells as
  a registered type error; DArrRef/DArrRef2 are for-loop borrows of middle
  arrays. None offers arbitrary-depth, shared, cyclic references.
- There IS a persistent tagged STATIC route (function-local STATIC Dyn,
  RefDyn/static_dyn) holding RETAINED scalar arrays (refcount at
  payload-16, scalars only, no nesting). Refcounts cannot represent cycles;
  S4 therefore uses the registry model below, not the retained-payload
  route.
- S4 object layout (new): 32-byte header {len, cap, registry_next,
  cells_ptr} + separate 16-byte-stride cell buffer {tag, payload}; tags:
  0 i64, 1 NIL, 2 logical, 4 owned string (hbc_strcpy allocation), 10
  SHARED ARRAY REFERENCE (payload = child OBJECT base; one tag for roots,
  cells, locals, params and returns). The cells buffer is separate so
  AAdd/ASize growth never moves the object identity that aliases and
  cycles point at. The registry root is a .data word; every object links
  through registry_next. Float cells are rejected in v1 (named limit), as
  are hash and codeblock cells.
- Binding model: a module dynamic array binds in every function as an
  ordinary Dyn local holding {tag 10, object pointer}. That single choice
  reuses the whole Dyn plumbing: LOCAL b := a copies the 16-byte pair
  (alias by construction); by-value parameters and returns carry the pair;
  the callee's epilogue and the move checker need ONE extension - tag 10
  release is a no-op and tag 10 clone copies the pointer - instead of a
  new CgLocal/Sig variant. len(), ValType() ("A"), hb_IsArray, `? name`
  (empty) and Index/ArrSet dispatch gain tag-10 arms beside tag 8.
  Because any Dyn cell may hold tag 10, a local owned array CAN store a
  shared reference (Harbour admits it; no owner-class mixing rule needed);
  the reverse (a shared array cell pointing at a single-owner local
  array) is rejected by the guard.

## The scope decision: unify, do not fork

Harbour has ONE array semantics: every module array literal is dynamic.
Keeping S3's flat-i64 fixed route for `{1,2,3}` while `{1,"x"}` goes
dynamic would fork behavior by cell content and permanently diverge from
Harbour on AAdd/ASize of flat arrays. Following the task instruction
("sigue Harbour (alias)"), S4 SUBSUMES S3: every module STATIC array
literal becomes a dynamic shared-reference array. S3's positive programs
remain byte-exact (reads/writes/len on untouched arrays behave
identically); S3's negatives split: AAdd/ASize/AIns/ADel/AFill, alias,
whole print, call argument, multi-level index and whole reassignment
become ADMITTED and move to the positive suite; @ borrows, containers
mixing owner classes, threads and blocks stay rejected. The S3 runner and
CI manifest rows move accordingly, with the boundary rewritten in the
docs. Flagged for the reviewer in the cover note.

## Open decisions flagged for review

1. No mid-run GC: registry grows until exit sweep. Acceptable for the
   guard-limited battery; a future increment could add pressure-based
   collection without changing admitted syntax.
2. The alias handle type is a new CgLocal/Sig form; it is the narrowest
   change that keeps existing DArr codegen paths (indexing, structural
   ops, printing) reusable unchanged.
3. p12-style out-of-range reads keep the registered failure-mode
   difference (hbc exits via hbc_bound_error; Harbour opens a dialog).

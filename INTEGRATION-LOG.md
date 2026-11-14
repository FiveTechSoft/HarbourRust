# Classes integration log (hr-int working copy)

Goal: land spike-validated classes/objects into hbc.rs in stages, keeping
the non-class battery green at every step. Objects = Dyn tag 13 (official
reassignment; 11/12 reserved for DBF worker). Scope: DATA scalars only,
methods + explicit New, single inheritance, no DATA object/array, no VM.

Base: main @ 3647b0b. Build: `rustc +1.99.1 --edition=2021 -O src/hbc.rs -o hbc`.

## Stage A (checker) - in progress

Pieces:
1. `Ty::Obj(u32)` - class table index. Exhaustive Ty matches patched
   compiler-guided; slot_size Obj = 8.
2. `ClassInfo` + thread_locals CLASSES / METHOD_CLASS (mangled fn name ->
   defining-class index). ClassInfo: name, parent, own_start, ndatas,
   datas (name->flat offset), slots (lowercase method name -> defining
   class fn name, hierarchy-wide constant slot index), ctor.
   Flat layout copied from spike: parent's slots cloned, overrides patched
   in place, new methods appended => dispatch slot is a compile-time
   constant per (receiver class, method name).
3. Driver prepass replaces the class gate (~20665): build table
   (errors: unknown parent, duplicate member, declared-but-undefined
   method, INIT over object/array), append method Funcs to `funcs` with
   implicit `Self` param at position 0.
4. Sig fixpoint hook: for method fns, ptys[0] = Obj(defining class),
   inferred[0] = true. Method ret seeded Dyn (tagged union; Harbour
   methods are dynamically typed).
5. type_expr arms (before the 6404 gate):
   - SelfObj (inside method) -> Obj(current class)
   - Send(recv, name, args): recv must be Obj(ci). Method-first lookup
     (cl10: method wins over same-name DATA): synthesize
     Expr::Call(mangled_fn, [recv] ++ args) and recurse - the receiver
     crosses as an explicit first argument so arity/NIL-padding/byref
     machinery works unchanged. DATA-only name -> Ty::Dyn (casilla
     read). Unknown member -> named error.
     Send on Dyn / non-object -> named rejections.
   - SelfGet(name) (inside method): method slot -> named error telling
     the user to call it; DATA -> Dyn; unknown -> named error.
6. check_stmts arms (before the 6969 gate):
   - SendStmt(recv, name, args) = Send for value discarded.
   - SelfSet(name, e) / SendSet(recv, name, e): DATA must exist on the
     class (else named error); e checked; assignment to a DATA casilla
     stores tagged (Dyn slot), value must be Dyn-representable scalar.
     Method name on the left -> named error (cl10 precedence is for
     reads; writes to a method name are rejected by name).
7. is-a assignment rule (~8300): env[idx].ty = Obj(b), value Obj(d)
   accepted iff d is-a b (walk parent chain).
8. apply_moves: Obj values are shared/refcounted - never mark moved.
9. Class programs still stop after checker with "class codegen pending
   (stage B)" until Stage B lands; class-free programs untouched
   (no-contamination gate stays byte-identical).

Named rejections for stage A: `? o` handled by print arm only in stage B;
!= on objects (BASE/1072 in Harbour) stays a named rejection; DATA
holding object/array; multiple inheritance.

## Stage B (codegen) - planned
- Class descriptors in rodata (per class: name, size, mtable of fn
  pointers, DATA INIT template, freelist head) + hrobj runtime blob
  embedded from spike asm/ recipe (validated blob).
- New/cg Send emission: 2 loads + indirect call; DATA access at
  compile-time offset.
- Object epilogue release on scope exit; hbc_print_dyn tag-13 arm
  (prints nothing, like Harbour `? o`).
- Gates: 18 positives + named negatives, no-contamination byte-identical,
  full Linux battery, ASan. Wine verification coordinated at landing.

## Stage A results (this run)
- hbc builds clean with rustc 1.99.1. Positive class probe (pos1.prg:
  inheritance, scalar INIT incl. function call, explicit :New(), virtual
  override, sends, SelfSet/SendSet via `::x :=`, is-a assignment, DATA
  reads) passes the checker and stops at the stage-B emit guard.
- 11 named negatives verified: unknown member, assign-to-method,
  object-in-DATA, Dyn send, non-object send, non-scalar INIT, duplicate
  DATA, declared-undefined method, unknown parent, class call with args,
  is-a violation, send-stmt on Dyn.
- Constructor typing: `:New()` returns the RECEIVER's class (the
  `local d := Dog():New()` idiom), even when the method is inherited.
- No-contamination: 1092/1093 manifest positives byte-identical asm vs
  pristine 3647b0b build (1 skipped: clean build itself fails on it);
  567/568 negatives byte-identical error output.
- Manifest change (flagged for review): t290_neg_class_gate's expected
  substring updated from "classes are not in this increment yet" to
  "code generation is stage B (pending)" - the old gate is gone by
  design; t290's counter program passes the checker now and becomes a
  positive runtime test when stage B lands.
- Registered parser surface (unchanged): SelfSet statement form is
  `::name := e`; `Self:name := e` at statement level is not in the
  subset (expression-level `Self:name` works). Class instantiation is
  `ClassName()` (zero args; `:New(args...)` on the instance).

## Stage A addendum (commit pending at write time)
- Cmp rules: `==` on objects = pointer identity (cl7/cl19) accepted;
  `!=`/`#` named rejection (BASE/1072); `=`/orderings on objects named
  rejections; object-vs-scalar (incl. NIL) named rejection.
- Parent approved (14 Nov 01:02): receiver-typed constructor result and
  the t290 manifest update. Deep review happens on the full A+B package;
  main is now 4e84240 (DBF hito 1 lands first; parent coordinates rebase).
- DESIGN-stage-B.md committed (f1b993a): runtime blob, descriptors,
  virtual dispatch (2 loads + indirect call), DATA access, ownership
  points, print tag-13, gates.

## Stage B piece 1 (this run)
- src/hrobj_blob.s: the spike's validated runtime blob adapted to hbc
  symbols (hbc_sfree -> hbc_freestr; hbc_alloc/hbc_strcpy verified
  ABI-compatible: alloc rdi=bytes->rax zeroed mapping; freestr rdi=data
  ptr; strcpy rdi=src rsi=len -> rax owned). NOT yet wired into
  emit_asm. Windows blob pending: compile hrobj_core.c with mingw at
  integration time (Wine verification coordinated by parent).

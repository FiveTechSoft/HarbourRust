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

## Stage B slice 1 (commit pendiente) - instantiation + DATA + ownership

Checker:
- Dyn local narrows to Obj on first object assignment (`local o; o := TClass()`);
  OBJ_NARROW thread_local hands the final class to both layout passes (lockstep).
- Obj slot: only same-class-or-descendant objects, or NIL (`o := NIL` releases).
  Reassigning to a scalar is a named rejection.
- INIT expressions type-checked post-checker (scalar-only, subset calls allowed).

Codegen:
- emit_class_runtime: per-class init fns + 10-quad descriptors + hrobj blob;
  `.text` restored after the blob (its tail sections are .note markers).
- Obj locals: 8-byte kind-9 slots, zero-init, epilogue hrobj_release.
- Obj := Obj shares: retain new THEN release old (fresh hrobj_new skips retain).
- Obj -> Dyn marshal tag 13 (retain); Obj -> Obj param retain; Obj -> Dyn param tag 13.
- DATA reads CLONE owned strings (Harbour value semantics; first version borrowed
  and `? o:s` double-freed the object's casilla - caught by v1-v3 probes).
- `? o`: live object prints empty but HOLDS its separator position; NIL slot
  prints NIL (oracle p_sep: "x  y" / "x NIL y").
- print blob + Dyn free paths emit their tag-13 arms ONLY when the program has
  classes (no-contamination: 1092/1092 positives byte-identical again, 568
  negatives identical except the manifest-tracked t290, now "method dispatch
  lands in stage B slice 2").
- parser accepts bare `CLASS Name [FROM|INHERIT Base]` too (CREATE CLASS stays).
- pp skips `#include "hbclass.ch"` (native classes; same .prg feeds hbc and
  real Harbour, which needs the header).

Probes (all byte-identical vs real Harbour @694428e1, /tmp/hrcls):
t1 (DATA rw + string overwrite + NIL release), t1b (sharing + identity ==),
t2 (INIT once/lazy/child-first via side-effect fn, inherited DATA rw),
t3 (all scalar types + NIL default), t4 (is-a reassignment),
p_sep (object print separators), neg4 (graduated to positive),
v1-v3 (release paths). neg1-neg13 still fire their named errors
(neg4 excepted, now positive).

Deferred to slice 2: method dispatch (named error today), object params'
member access inside callees (receiver class pinning), :New() runtime.

## Slice 3 (rebase sobre NTX main 9a6f3b4 + New por defecto + pinning de receptor)

Rebase: 6 commits re-aplicados sobre 9a6f3b4 (v0.5.0 NTX + README).
Conflictos reales: tests/manifest.txt (main renombro .hb->.prg; se toma
la forma de main y se conserva el mensaje aprobado de t290) y dos
bloques de src/hbc.rs donde el commit DBF 9f578a3 introdujo los
marcadores @HBC_TAG_KIND@/@HBC_TAG_END@ (finalize_tag_kind_accessors
estrecha las comparaciones de tag a byte bajo en modo DBF). Resolucion:
toda comparacion de tag en mis caminos de clases va envuelta en los
marcadores (free Dyn, epilogo kind 7, retain de return Dyn, descarte
SendStmt). Hallazgo post-rebase: el commit DBF tambien marco el cmp $8
del blob de print, lo que dejaba MI replace() del brazo tag-13 como
no-op silencioso; patron actualizado a la forma marcada + debug_assert
para que un replace sin efecto sea ruidoso. Verificacion post-rebase:
1007/1007 positivas byte-identicas, 567/567 negativas, suite de clases
25/28 (p03/p07 '=' del subset, p21 MI: limitaciones aprobadas).
t290_neg_class_gate ahora compila y corre byte-identico al Harbour real
(create class + constructor + metodos): la entrada neg del manifest se
convierte en pos con la salida del oraculo.

New() por defecto (p16, plan aprobado): build_class_table anade el slot
("new", ClassName__new) cuando ni la clase ni sus ancestros lo tienen;
main() materializa el Func sintetizado (`return Self`) y lo registra en
METHOD_CLASS antes del loop de inferencia. Un CONSTRUCTOR explicito bajo
otro nombre sigue siendo el constructor de tipado. p16 byte-identico
(INIT lazy child-first verificado: "INIT C" antes que "INIT P").

Pinning de receptor por parametro (p12, diseno aprobado): un send sobre
un PARAMETRO lo pinea a la RAIZ de la unica jerarquia que posee el
miembro (offsets de DATA y slots de metodos son planos por jerarquia,
asi que cualquier instancia de la jerarquia encaja). Harbour resuelve el
miembro en runtime; nosotros acotamos en compilacion - NO es late
binding general. Miembro poseido por dos jerarquias: error nombrado de
ambiguedad (neg14), que adelanta al error generico del checker. Hooks:
walk(Expr::Send) y walk_stmts(Stmt::SendSet) en pin_params. p12 y p24
(dispatch virtual a traves de parametro pineado) byte-identicos.

Sondas nuevas: neg14_ambig_member (error nombrado), p24_param_virtual
(byte-identico al oraculo). Suite: 25/28 PASS + 13 negativas con rechazo
nombrado limpio.

## Slice 3 continuacion: estrechamiento en bucles + estres de heap

p25_stress (2000 ciclos Node():New()/Bump/release por iteracion, freelist
reciclando) destapo un panic real: el estrechamiento Dyn->Obj de un local
dentro de un cuerpo FOR lo descartaba la env final del checker, asi que
OBJ_NARROW no lo veia y el layout de codegen dejaba el slot Dyn (panic
unreachable en el Send). Fix: OBJ_NARROW se registra EN el punto del
estrechamiento (checker, brazos Local y Assign), no solo desde la env
final. p25 byte-identico al oraculo Harbour e instantaneo.

Verificacion final del paquete:
- Bateria Linux (mitad de tests/run_battery.sh, mismas banderas y
  aceptacion): 1660/1661; el unico fallo es t110_pp_include_angle_neg,
  HEREDADO de main (falla identico en 9a6f3b4 pristino; lo documenta el
  propio commit DBF 9f578a3)
- No-contaminacion: 1007/1007 positivas byte-identicas, 567/567
  negativas (compilador pristino 9a6f3b4 vs integracion)
- Suite de clases: 26/29 byte-identicas (p03/p07 '=' del subset y p21 MI
  son las limitaciones aprobadas) + 13 negativas con rechazo nombrado
- ASan+UBSan: blob de integracion src/hrobj_blob.s bajo el driver C del
  spike (gcc -fsanitize=address,undefined), incluido el caso cero-DATA
  del template dummy: limpio, OK

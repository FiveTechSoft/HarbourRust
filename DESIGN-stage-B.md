# Stage B (codegen) design - classes tag 13

Base: stage A commit 4b70877. Spike evidence: ~/hr-classes-spike
(harness 18/18 byte-exact vs Harbour @694428e1, ASan clean; asm blob
validated by asm/blobtest.c). NO Harbour code copied (MIT).

## B1. Runtime blob
Embed ~/hr-classes-spike/asm/hrobj_blob.s (217 lines, validated) as a
const string appended to the emitted runtime helpers (alongside
CONSOLE_NUL_HELPER). Symbol adaptations needed:
- hbc_sfree -> hbc_freestr (exists in hbc runtime, rdi=ptr).
- hbc_alloc exists (rdi=bytes -> rax). hbc_free: declared in the spike
  core but never called by hrobj_core - drop the extern.
- Blob is pure asm text; label namespace hrobj_* cannot collide with
  hbc's numbered labels.
Runtime facts (spike, all measured): header {cls, refc} + ndatas Dyn
casillas; lazy child-first INIT template (tpl_build once, oracles
p10/p10b/p16/p16b); instantiation = template copy + owned-string clone;
freelist per class, link in refc word (NOT data[0]; ndatas=0 classes
work); release frees tag-4 casillas then recycles into freelist;
chunked arena (4KB) behind the freelist.

## B2. Class descriptors (.data) + method tables (.rodata)
Per class i: hrobj_desc_<i>:
  .quad name_str            ; .rodata
  .quad parent_desc_or_0
  .long own_start, ndatas
  .long nslots, pad
  .quad mtable              ; .rodata: nslots fn pointers, slot order
  .quad init_own_fn_or_0    ; hrobj_init_<i>
  .quad tpl (0)             ; lazy
  .quad freelist (0), chunk_left (0), chunk (0)
INIT own fn: hrobj_init_<i>(rdi=HRDyn *t): for each own DATA with INIT,
evaluate the expr (scalar-only by stage-A gate) and store the tagged
pair at t[own_start+k]. Exprs reference no locals (calls/arithmetic/
literals) - cg via existing expr emitter with an empty env; strings
store as OWNED tag-4 copies (hbc_strcpy) so the template never aliases
rodata (template strings are cloned again per instance by hrobj_new).

## B3. Instantiation  Animal()
cg arm for Expr::Call(id, []) when class_find(id).is_some():
  lea hrobj_desc_<i>(%rip), %rdi
  call hrobj_new            ; rax = obj ptr (C ABI: HRObj*)
  mov %rax, %rdx
  mov $13, %rax             ; Dyn pair rax=13, rdx=obj
Value type Obj(i); as a Dyn casilla it is {13, ptr}.

## B4. Virtual dispatch (send) - the speed core
CHECKER keeps the synthetic-Call trick (type checking only). CODEGEN
must NOT emit a direct call to the statically resolved fn: the receiver
may hold a descendant. cg arm for Expr::Send(recv, name, args):
  - slot = compile-time constant from method_lookup (hierarchy-wide).
  - emit recv -> rdx = obj ptr.
  - mov (%rdx), %r10                ; cls
  - mov MTABLE_OFF(%r10), %r10      ; mtable
  - mov slot*8(%r10), %r10          ; fn ptr  (2 loads + indirect call)
  - marshal args (Self = obj ptr first, per hbc fn-call ABI)
  - call *%r10
Method ABI = ordinary hbc function with Self as param 0 (pointer word,
size_of(Obj)=8). Return: method sig ret; constructor-call RESULT TYPE
was fixed by the checker to the receiver class - expr_ty(Send) must
mirror that (expr_ty arm at ~10781 currently returns Dyn: replace with
the real resolution; constructor -> Obj(receiver)).

## B5. DATA access
Read  o:x  (off = compile-time constant):
  recv -> rdx;  mov 16+off*16+8(%rdx), %rax?? NO: casilla = {tag,payload}
  mov 16+off*16(%rdx), %rax    ; tag
  mov 24+off*16(%rdx), %rdx    ; payload   -> Dyn pair
Write o:x := e:
  cg e -> Dyn pair (rax,rdx); old casilla tag==4 -> hbc_freestr(old)
  (tag 13 impossible in v1: object-in-DATA is a stage-A rejection);
  store new pair. SelfSet: recv is param 0 (Self). `::x` read = SelfGet.

## B6. Ownership / refcount points
- local b := a (Obj): RETAIN a (call hrobj_retain) after the copy.
- Reassignment over an Obj local: RELEASE the old value first.
- Function/method exit: release Obj locals (and Obj params, whose
  boundary RETAINED them) in the epilogue next to the existing string
  frees. DECISION POINT: call boundary retains for every Obj argument,
  callee releases its slot at exit (uniform ownership; matches the
  registered sharing semantics). Verify against epilogue code before
  writing; Dyn slots holding tag 13 release via tag check.
- Dyn slot acquires an object (u := a): retain on store; the existing
  Dyn release paths must learn tag 13 (search Dyn overwrite/free sites).

## B7. Comparisons and print
- == on (Obj,Obj): pointer identity (cl7/cl19) -> Bool.
  != on objects: named compile-time rejection (Harbour BASE/1072 dialog;
  registered acceptance from spike 1). Add to type_expr Cmp arm.
- `? o`: print nothing (oracle p23). cg print arm for Obj: build Dyn
  {13,ptr} and route through hbc_print_dyn; add tag 13 to its `13: ret`
  no-print arm in BOTH blobs (Linux ~17096, Windows ~19263).

## B8. expr_ty + remaining cg arms
expr_ty: SelfObj -> Obj(cur method class); SelfGet -> Dyn; Send ->
resolved (B4). cg arms to write: Expr::SelfObj (load param 0 word),
SelfGet (DATA read via param 0), Send (B4/B5), Stmt::SendSet/SelfSet
(B5), SendStmt (B4 discard). Existing unreachable!("class codegen
pending") arms at 9050-ish/12148-ish get replaced as each path lands.

## B9. Gates before reporting stage B
1. The 18 spike positives as .prg compiled by hbc, run on Linux,
   byte-exact vs oracle captures.
2. Named negatives battery (11 from stage A + != on objects).
3. No-contamination: manifest positives byte-identical asm vs pristine
   main-of-the-moment (parent: main now 4e84240; DBF hito 1 lands
   first - parent coordinates rebase).
4. Full Linux battery + ASan on the runtime paths.
5. Wine: coordinated with parent at landing (no Wine in my box).

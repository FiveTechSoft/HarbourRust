# LLVM Empty on immutable borrowed constant strings

Own MIT bounded backend increment. Empty reads only existing immutable
borrowed literal-string locals or pure borrowed constant trees. No Dyn,
owned/mutable string ABI,storage,aliasing or new frontend admission. Existing
scalar/fixedarray paths unchanged. Fresh Harbour ASCII sweep0..127 measures
exact whitespace setTAB9,LF10,CR13,SPACE32;VT11,FF12,NUL0 are not empty.
String evaluation folds all bytes against that measured set. UTF8 bytes
remain nonblank. No C locale whitespace inference or Unicode trim used.

Gate10:two sources native/traced/untraced=6fresh exactHarbour triples,4named
mutable/owned limits. All128ASCII cases,empty/mixed/control/NUL/UTF8 locals,
branch use and priorLen covered. Existing206sourceLLVM618comparisons exact
against native,not freshHarbour. Linux1185exact,618negative2targetstatus/
diagnostics identical to predecessor4c0f7019,census1041/60unchanged.
Mandatory57originals340clean+2knownDELTA2,freshforeach-empty28 including
promotedlimit-local. Rust106,Python66=64pass2skip;PE1912/26known/0FAILemission.
No nativeMacruntime,fullhistoricalsuites or performance rerun/claim.

Compilerf0c010fcf279c12f7e199cb4a450a7706bc9411a402608432b3cecb11ba356a0.
Source/command/cwd/raw/oracleLLVMhashes retained. JulioPonceMIT specifications
credited elsewhere,no suppliedimplementation/cambio.diff copied. NoASort,
numericdivision,RC/objectlifetime,workflow,push,publication,rebase changes.

## Immutable local concat trees

Follow-up: resolve immutable local bindings recursively in pure concat
operands. Fixed-array and numeric/logical behavior remains unchanged. No
owned/mutable/runtime string admission. New empty/space/NUL/ASCII/UTF8
and numeric/logical/control-context fixtures plus owned-subtree negative.
Own gate: 9 fresh Harbour/native/LLVM exact rows, 6 named LLVM rejections.
Broad current evidence is listed separately in the package summary.

## Empty-only lazy immutable selection

Empty observes constant string leaves of nested IIf through logical scalar
projection, retaining all reached conditions exactly once and lazy. Both
arms must prove immutable constant leaves before lowering, including dead
owned leaves (rejected). No runtime string value ABI, ownership change or
new direct alias policy. Empty keeps measured tab/LF/CR/space semantics,
with NUL and UTF8 nonempty. Gate total:12exact fresh Harbour/native/LLVM
rows and8named LLVM rejections. Bounds-failing unselected conditions,
increments, loop/logical/IF/IIf contexts covered.

## Empty of literal NIL

A direct Empty(NIL) is the constant logical true. This observes a literal
without a NIL scalar sentinel,local storage,return/parameter ABI or selection
value support. Two own MIT sources cover local logical bindings,nesting,
comparisons,short-circuit effects,IIf and loops against fresh Harbour in
native/traced/untraced modes. Two named negatives keep NIL local storage
and NIL-valued IIf rejected. Existing fixed-array and string paths unchanged.

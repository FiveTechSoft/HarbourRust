# LLVM Len on borrowed constant strings

Own MIT bounded backend increment. Len accepts existing immutable borrowed
constant string locals and pure borrowed constant trees(literal strings,
concatenation and literal ASCIIChr0..127). Returns byte length,including
UTF8/control/NUL bytes,not Unicode character count. No owned string ABI,
mutable string storage,new frontend admission,ownership or RC model.
Existing fixedI64array Len unchanged. Mutable and owned-computed locals
remain named rejections. Both traced and untraced LLVM execute the result.

Gate10fresh:2positive fixtures x native/traced/untraced=6exactHarbour triples,
4specificdiagnostic limits. Existing206sourceLLVMregression=618exact native/
traced/untraced against each other,not freshHarbour. Linux1185exact,618negative
identical to preincrement263bde6d onLinux/PE,census1041/60unchanged.
Mandatory57originals285exact+55zero=340clean,2knownDELTA2separate. Rust106,
Python66=64pass2skip,PE1912/26known/0FAILemissiononly. No nativeMacruntime,
fullhistorical suites or performance rerun.

Failed setup preserved:not counting four intentionallimits as positivefixed
runnerassert;attempted userLen oracle was rejected by Harbour as predefined
functionredefinition,fixture removed from oracle gate. Neither isPASS.
No compiler semantics weakened to admit those attempts. Source/commands/
rawexecution/oraclehash/LLVMlibhash/compilerhash included. Original sources
are specifications,JulioPonceMIT examples credited elsewhere,no supplied
implementation/cambio.diff copied. NoASort,division,RC/objectlifetime,
workflow,push,publication,rebase changes.

## Immutable local concat trees

Follow-up: resolve immutable local bindings recursively in pure concat
operands. Fixed-array and numeric/logical behavior remains unchanged. No
owned/mutable/runtime string admission. New empty/space/NUL/ASCII/UTF8
and numeric/logical/control-context fixtures plus owned-subtree negative.
Own gate: 9 fresh Harbour/native/LLVM exact rows, 6 named LLVM rejections.
Broad current evidence is listed separately in the package summary.

## Length-only lazy immutable selection

Len can observe the byte length of a nested IIf whose leaves are pure
immutable borrowed constant trees. Uses the existing pointer/length selector,
not a general string value ABI. Only reached conditions execute once; every
leaf must pass structural constant proof. Frontend heap moves are unchanged,
so fixtures that reuse local leaves concatenate an empty string explicitly.
Owned arms stay rejected even when unreachable. Gate total:12exact fresh
Harbour/native/LLVM rows,8named LLVM rejections. No ownership/RC change.

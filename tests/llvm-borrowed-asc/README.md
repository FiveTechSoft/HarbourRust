# LLVM Asc on immutable borrowed constant strings

Own MIT bounded backend increment. Asc accepts existing immutable borrowed
constant locals and pure literal/concatenation/ASCIIChr trees. Returns first
unsigned byte,or0for empty string. No Unicode codepoint decoding,owned or
mutable string ABI,Dynstorage,ownership or frontend admission. Fresh Harbour
sweep128ASCII plus UTF8 measured195/228/240for á/中/🙂,and0forempty/NUL.

Gate10=6freshHarbourtriples(two sources,native/traced/untraced)+4namedlimits.
Existing206sourceLLVM618comparisons exact against native,not freshHarbour.
Linux1185exact,618negative2targets identical to priorf0c010fc,census1041/60
unchanged. Mandatory57originals340clean+2knownDELTA2. Rust106,Python66=
64pass2skip;PE1912/26known/0FAILemissiononly. No nativeMacruntime,allhistorical
suite or performance claim. Compiler56c6147750c0a35f9d224cfbe8530e08140fd5dc2577723c3a20da814933b7ee.

Source/command/cwd/raw/oracleLLVMhashes retained. JulioPonceMITspecifications
credited elsewhere,no suppliedimplementation/cambio.diff copied. NoASort,
numericdivision,RC/objectlifetime,workflow,push,publication,rebase changes.

## Immutable local concat trees

Follow-up: recursively resolve immutable locals within pure concat operands.
No owned/mutable/runtime string support, evaluation erasure or locale policy
change. ASCII predicates still reject a non-ASCII first byte. Asc continues
to return the first counted byte, including NUL/UTF8. Added empty/NUL/ASCII,
UTF8 and logical/numeric/control-context fixtures and owned-subtree limits.
Current evidence and exact counts are listed in the package summary.

## Asc-only lazy immutable selection

Asc observes constant leaves of nested IIf through I64 first-byte projection.
Reached conditions remain lazy and execute once. Both arms must prove pure
immutable leaves, including unreachable owned leaves (rejected). No runtime
string ABI, direct alias or ownership change. Empty gives0; NUL/ASCII/UTF8
first-byte semantics stay unchanged. Gate total12fresh exact Harbour/native/
LLVM rows plus8named LLVM rejections. Repeated loops, increments and skipped
bounds-error condition covered. Broad current evidence in package summary.

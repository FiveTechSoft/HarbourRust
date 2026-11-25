# LLVM exact equality of borrowed constants

Own MIT increment: == between two immutable borrowed constant strings,
including immutable locals and existing pure concat/ASCIIChr constant trees.
Exact byte equality,including length,NUL,UTF8,trailing spaces and case.
No SETEXACT,loose=,inequality,ordering,collation,codepage or ownership expansion.
Both operands must be constant-borrowed,no argument effects can be erased.

Own14rows:2sourcesx3routes=6freshHarbour byte-exact,8namedrejections for
mutable/owned/loose=/!= across2LLVMmodes. Empty,prefix,spaces,NUL,UTF8,
logicalvariables/NOT/AND/IF/IIf/Empty covered. No frontend change.
Fresh Rust118,Python64pass2skip,Linux1185,negative618x2same,23frontier425,
charpred14,57original285exact+55zero+2knownDELTA2separate. FullLLVM1185scan
357admittedx3=1071exactmanifest,828reject,notfreshHarbour. Manifest resumed
from completed command/rc/stdout/stderr records after timeout;runner included.
Errors69native/traced/repeat and12canaryemission pass. No censusrerun,
PEruntime/Mac/performance/allhistorical claim. No ABI/RC/numericdivision/
workflow/push/publication/rebase. JulioPonceMITexamples specifications only,
no implementation/cambio.diff copy. Oracle694428e1c12f726675b19324d62167fa77d68185.

## Immutable local concat trees

Follow-up: resolve immutable local bindings recursively within pure concat
operands of ==, using the same constant-only resolver as $. No runtime
string/owned/mutable expansion. Added NUL, UTF8, empty, trailing-space,
logical/IF/IIf/Empty and false/true concat-tree checks, plus an owned-subtree
negative. Own gate now 9 fresh Harbour/native/LLVM exact rows and 10 named
LLVM rejections. Broader current results are listed in the package summary.

## Constant against selected right operand

Exact == against a nested IIf constant right operand projects leaves to
logical results. Left operand must remain immutable constant. Both selected
operands and owned dead leaves remain rejected. Every leaf proved before
lowering;selected conditions once/lazy. No string ABI,loose equality,SETEXACT,
RC or mutable expansion. Two own MIT cases fresh Harbour/native/LLVM traced/
untraced cover empty,prefix,spaces,case,NUL,UTF8,effects,lazy bounds/overflow,
logical/IF/Empty contexts.Two named limits added.

## Selected-right ASCII matrix

Own MIT test-only sweep of128ASCII bytes,including NUL,compares each byte
against alternating equal/suffixed selected strings. Checked increment
conditions and printed counters measure single evaluation on both branches.
No compiler change or original edits.

## Selected left operand against a constant

Own MIT follow-up projects the left IIf tree to exact logical leaves when
the right operand is immutable constant. Conditions remain single/lazy.
UTF8,NUL,space,prefix,case,nested effects and dead bounds/overflow covered.
Owned dead leaves and both-selected operands still rejected. No string ABI.

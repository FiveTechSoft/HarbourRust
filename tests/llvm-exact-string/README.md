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

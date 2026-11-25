# LLVM borrowed ASCII character predicates

Own MIT increment. IsDigit/IsAlpha/IsUpper/IsLower inspect the first byte of an
immutable borrowed constant string. Empty false,ASCII ranges only. NonASCII
first byte explicitly rejects,not locale/codepage emulation. Existing borrowed
constant concat/ASCIIChr trees and immutable locals only. Returns logical,
including print/type propagation. No allocation,ownership or frontend change.

Own14rows:2sourcesx3routes=6freshHarbour byte-exact plus8namedrejections
(mutable,owned,nonASCII,userfunctioncollision x2LLVMmodes). IsDigit is already
reserved in the frontend;this increment does NOT add override support.
Ascii boundaries,empty/NUL/control/DEL,firstbytevsrest,locals,logical variable,
condition,IIf,Empty and pure constant trees covered. Attempted override test
revealed existing reservation,retained as rejection rather than changing policy.

Fresh Rust118,Python64pass2skip,Linux1185,negative618x2same,23frontier425;
57original285exact+55zero,2knownDELTA2separate. FullLLVM1185scan357admitted
x3=1071exactmanifest,828reject,notfreshHarbour. Error69native/traced/repeat
triples and12frozencanary emissionchecks pass;Windowsruntime not executed.
Census not rerun,frontend unchanged. No fullPE/Mac/performance/allhistorical
claim. No numericdivision/ABI/RC/workflow/push/publication/rebase changes.
JulioPonceMITexamples specifications only,no implementation/cambio.diff copied.
Oracle694428e1c12f726675b19324d62167fa77d68185.

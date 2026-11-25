# Linux-host Linux LLVM GTSTD console profile

Own MIT fix of existing LLVM divergences, not new expression admission.
Reuses the current native Linux GTSTD renderer in the LLVM runtime sidecar.
A sidecar-only profile does not enable native frontend features. Formatted
render boundaries select console mode, flush after the statement, and reset
raw mode. Arguments still evaluate before the outer render begins. OutStd
stays raw and does not alter console screen state. Existing exit/fatal close
hooks come from the same sidecar helpers. No runtime renderer source copy.
Windows, Darwin and threaded profiles retain their previous paths.

Five own sources x native/LLVM traced/untraced = 15 fresh Harbour byte-exact
triples. Includes controls/NUL/BS/bell/CR/LF, 80-column wrap, 27 lines, held
spaces, empty fragments, formatted/raw interleaving, and argument output
with integer increments/call return. No byref or string ABI expansion.
The original failed probes were not passes. Broad current results are
recorded in the package summary. No policy/RC/numeric-division change.
No push/publication/workflow/rebase. Harbour oracle commit
694428e1c12f726675b19324d62167fa77d68185. MIT upstream examples are
specifications only; Julio Ponce examples credited, no cambio.diff copy.

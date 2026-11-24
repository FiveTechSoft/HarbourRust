# Nested tagged cell replacement and literal ValType

Own MIT increment on 6156f6e5a5af995443475d01b9b6d4841d6c4d09.
No workflows, push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains with the unchanged ASort specifications.

A constant local array receiving a constant nested tagged array into one
cell now activates the existing shared identity route. This reuses tagged
cell writes, alias propagation and collection; no runtime helper is added.
The trigger requires a literal local root and a literal replacement with
a nested array and string/NIL/logical leaf. It does not enable general
computed literals, macros or other-target shared identity.

ValType of a side-effect-free constant array literal yields A in ordinary
Linux decimal profile. No array allocation is needed for that observation.
The compiler's existing shared literal predicate defines this boundary.

Gate18: two own fixtures, 10 exact fresh-Harbour executions in five modes,
2 zero final balances, 6 other-target rejections. Covers nested replacement,
mixed/chained index stores, aliases, constant literal ValType and repeated
replacement/collection. A failed exploratory Len of a nested string cell
was removed from the positive fixture, not treated as a pass. That Len
shape remains outside this increment.

Original arrays/array16 are NOT closed. They progress to ATail of shared
arrays, which remains unsupported. No original execution claim is made.

ASort2 gate correction: 58 = own42 + originals16. The previous optional
glob could silently omit Julio c01/c04 and print PASS42. Both originals
are now mandatory, and the gate prints the split. A missing-source test
must exit with argparse status2, not a partial PASS. No compiler mismatch
was found in that discrepancy. See tests/asort-phase2/README.md.

    python tests/nested-cell-replacement/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/nested-cell-replacement-gate

Validation: 55 prior suites PASS, Rust104, Linux1177 stdout goldens exact,
PE1912PASS22known0FAIL emission only, negatives622 combined16 unchanged
(Linux7/Windows9). Census54/1041 unchanged; only arrays/array16 diagnostics
advance to ATail. No performance claim. Initial Rust test launch hit a
PATH permission issue; rerunning the installed toolchain passed all104.

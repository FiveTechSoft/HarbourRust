# ValType of shared paths at depth two through four

Own MIT increment on b583f19b7e8e7154b88f88eb91e2710f9c23fcea.
No workflows, push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

ValType now accepts indexed paths of2..4 levels on already-selected local
shared dynamic roots. The existing indexed read checks each intermediate
array and bounds and returns a borrowed tagged value; ValType classifies
that tag without allocating/cloning the payload. Unique-array legacy
classification stays untouched. This does not activate shared identity or
add arbitrary expression shapes, module-only roots or other profiles.

Gate18: two own sources x5modes=10 exact fresh-Harbour executions,2 zero
final balances,6 other-profile rejections. Covers depths2/3/4,NIL,logical,
string,float,date,integer,array child,mixed/chained groups,left-to-right
index effects,alias mutation and repeated borrowed classification.
No original newly closes.

59 prior suites PASS including intact arrays/array16 in five Linux modes.
Rust104,Linux1177 stdout goldens exact,PE1912PASS22known0FAIL emission
only. Negatives622 combined16 unchanged (Linux7/Windows9). Census56/1041
with no admission or diagnostic changes. No performance claim. ASort2
remains58=own42+originals16 with mandatory original source files.

    python tests/shared-nested-valtype/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-nested-valtype-gate

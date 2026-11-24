# ValType of a shared ATail result

Own MIT increment on14b5895905ef1fb38ec74b1ca2304b81da266aaa.
No workflows, push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

ValType(ATail(a)) is now admitted only for a variable already selected by
the shared-array route. The inner ATail is checked and evaluated normally,
its runtime tag classified, and its owned string/float temporary released
while preserving the resulting type letter. This does not enable arbitrary
call expressions under ValType, nonvariable ATail arguments or activate
shared identity. No runtime helper added.

Gate18: 10 exact fresh-Harbour executions (two own fixtures x5modes),
2 zero final balances,6 other-profile rejections. Measures empty NIL,
integer,string,float,logical,date,nested array and repeated owned-result
cleanup. An initial fixture used b[7,1] for the sixth element and hit
Harbour's interactive bounds-error handler; it timed out, not a pass.
Corrected b[6,1] passes the full gate. No original newly closes.

57 prior suites PASS including the intact arrays/array16 differential gate,
Rust104, Linux1177 stdout golden rows exact, PE1912PASS22known0FAIL
emission only. Negative622 combined16 unchanged (Linux7/Windows9).
Census56/1041 with no admission or diagnostic changes. No performance claim.
ASort2 remains58=own42+originals16 with mandatory original files.

    python tests/shared-tail-valtype/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-tail-valtype-gate

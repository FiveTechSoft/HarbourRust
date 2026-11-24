# Len of shared paths at depth three and four

Own MIT increment on0752807889cdcb8117c2351deac42720a1ed5e2e.
No workflows, push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

Len(a[i,j,k]) and Len(a[i,j,k,l]) now accept already-shared dynamic
roots. Type checking uses the existing shared indexed read validation;
code generation reuses the existing two-level runtime length dispatch.
The cell is borrowed, not cloned. A shared child array returns its count;
a string returns its byte length. Other tags take the existing native
type error, not a claim of equal Harbour default-handler output. Bounds
and intermediate array checks remain the shared read checks. This does
not activate shared identity, change unique arrays or enable other profiles.

Gate18: two own fixtures x5modes=10 exact fresh-Harbour executions,
2 zero final balances,6 other-profile rejections. Covers depth3/depth4,
strings,empty strings,child arrays,mixed/chained index groups,observable
left-to-right index evaluation,alias mutation and repeated borrowed reads.
No original newly closes.

58 prior suites PASS including intact arrays/array16 in five Linux modes.
Rust104, Linux1177 stdout goldens exact, PE1912PASS22known0FAIL emission
only. Negatives622 combined16 unchanged (Linux7/Windows9). Census56/1041
with no admission or diagnostic changes. No performance claim.
ASort2 remains58=own42+originals16 with mandatory originals.

    python tests/shared-nested-len/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-nested-len-gate

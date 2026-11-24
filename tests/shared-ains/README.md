# AIns of an already shared array

Own MIT increment on54be10e71c18b1af7d20417e082be319f668fb65.
No workflows,push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

AIns of an already-selected local shared array uses its canonical object
length/cell buffer with the existing fixed-length insertion machinery.
The index evaluates once before loading the root. Zero clamps to1,negative
and beyond-length indexes are no-ops. Last string/float payload is freed;
shifted cells transfer ownership,inserted cell becomes NIL. Child arrays
remain registry-owned,never individually freed. Length/object identity
stays unchanged,so aliases see the shift. Saved length uses preserved
r12 with balanced/aligned stack. Legacy tag8 path unchanged.

Gate18:two own fixtures x5modes=10 exact fresh-Harbour executions,2 zero
final balances,6 profile rejections. Covers mixed payload shifts,dropped
float/string/child cells,retained child alias,empty array,index0/negative/
out-of-range/tail and repeated shifts/release. No original newly closes.

Original ains now executes its first three scenarios exactly,then fails
on ADel at line34,which still expects legacy tag8. Its partial raw output
is included,not a closed-original claim. Census57/1041 unchanged.
68 prior suites PASS (35 first batch +33 rest). Both broad wrappers hit
outer timeouts;missing Linux sweep was rerun in isolation,1177stdout exact.
Rust104,PE1912PASS22known0FAIL emission only,negative622 combined16
unchanged(Linux7/Windows9).No performance claim. ASort2 remains58=42+16
with mandatory originals.

    python tests/shared-ains/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-ains-gate

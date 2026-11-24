# ADel of an already shared array

Own MIT increment on30f7a3ddc4c3cab65f98473a07dc4a3d3099bc24.
No workflows,push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

ADel on an already-selected local shared array uses its canonical object
length/cells with the existing fixed-length deletion machinery. Index
evaluates once before root load,zero clamps1,negative/out-of-range no-op.
Deleted string/float is released;shifted pairs transfer ownership and tail
is NIL. Child arrays remain registry-owned and aliases remain valid.
Length/object identity unchanged. Saved r12 and stack alignment mirror
shared AIns. Legacy tag8 path unchanged,no new helper or activation.

Gate18:two own fixtures x5modes=10 exact fresh-Harbour executions,2 zero
final balances,6 profile rejections. Covers mixed payload deletion,
retained child alias,tail NIL,empty,zero/negative/outside/tail indexes
and repeated shifts/release. No original newly closes.

Original ains executes its first5scenarios,then fails AFill at line44
with the legacy tag8 guard. Partial output is included,not an intact
original execution claim. Census57/1041 unchanged.69 prior suites PASS
(split35+34),Rust104,Linux1177 stdout exact,PE1912PASS22known0FAIL
emission only,negative622combined16 unchanged(Linux7/Windows9).
No performance claim. ASort2 stays58=42+16 with mandatory originals.

    python tests/shared-adel/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-adel-gate

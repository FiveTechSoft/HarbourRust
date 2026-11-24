# Literal AClone selects shared identity

Own MIT increment on e0583f854943bfa9114d7ea0c829f34da38f7d7c.
No workflows,push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

An explicit AClone of a side-effect-free constant array literal now
selects the existing shared-array route. The preceding bounded clone
lowering and destination-name propagation do the work; this increment
adds only the activation trigger. No support for cloning existing shared
variables,computed literal elements,macros/threads/other target profiles.
No runtime helper.

Gate18:two own fixtures with no artificial shared activation,x5modes=
10 exact fresh-Harbour executions,2 zero final balances,6 profile
rejections. Covers independent empty/nested/mixed/float/date literal
clones,mutation,alias propagation and repeated replacement/collection.

No intact original newly closes. Original ains passes its initial AClone
but now rejects the later IIF(StrOwn,Dyn) at line80. Census56/1041,only
ains diagnostic changes.66 prior suites PASS,Rust104,Linux1177 stdout
goldens exact,PE1912PASS22known0FAIL emission only. Negatives622
combined16 unchanged(Linux7/Windows9).No performance claim.
ASort2 stays58=own42+originals16,mandatory original source files.

    python tests/literal-clone-entry/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/literal-clone-entry-gate

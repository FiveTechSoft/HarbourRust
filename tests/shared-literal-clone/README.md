# AClone of constant literals in an existing shared context

Own MIT increment on382a879ea1c1639e9d2f967bbd3e6136f90d6cc6.
No workflows,push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

When shared identity is already active,AClone of a side-effect-free
constant array literal uses the existing literal descriptor builder to
construct the result directly. Literal children cannot refer to existing
objects,so constructing the result avoids an unobservable source object.
Results assigned to local variables join the existing shared-name
propagation,including aliases and collector roots. This is NOT AClone of
an existing shared variable or arbitrary expression,and does not activate
shared identity. Those remain rejected. No new runtime helper.

Gate18:two own sources x5modes=10 exact fresh-Harbour executions,2 zero
final balances,6 other-profile rejections. Covers empty,integer,string,
float,date,nested literal clones,separate calls with independent results,
mutations,local assignment,repeated replacement and collection.
No original newly closes;ains still rejects its ordinary nonshared
AClone literal. Do not confuse this bounded context with general AClone.

65 prior suites PASS including arrays/array16 intact in five Linux modes.
Rust104,Linux1177 stdout goldens exact,PE1912PASS22known0FAIL emission
only. Negatives622 combined16 unchanged (Linux7/Windows9). Census56/1041
with no admission or diagnostic changes. No performance claim. ASort2
remains58=own42+originals16 with mandatory originals.

    python tests/shared-literal-clone/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-literal-clone-gate

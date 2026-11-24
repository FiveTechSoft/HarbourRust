# Graph AClone of an already shared local array

Own MIT increment on a5a5a84bfafa4124ac0879853ca7b6dba36912d3.
No workflows,push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

AClone of an already-selected shared array variable builds a new registered
graph. An invocation-local old/new map is populated before visiting child
cells,so repeated children stay repeated and cycles point inside the clone
rather than into the source. Strings and heap floats are cloned;other
scalar pairs copy. Temporary map allocations are freed before return.
There is no collector safe point during construction;the normal caller
root/statement-boundary collector owns the returned graph. Destination
name propagation keeps cloned locals on the existing shared route.

This adds a native graph helper. Map lookup is linear and traversal is
recursive: no large-graph performance or extreme-depth stack guarantee.
No arbitrary expression arguments,identity activation,legacy unique-array
changes or other-target support. Shared parameter variables use the same
existing name/typing contract. The literal-clone fast path is unchanged.

Fresh oracle probe confirmed shared-child preservation and self-cycle
remapping before implementation. Initial gate18:two own sources x5modes=10 exact
fresh-Harbour executions,2 zero final balances,6 profile rejections. Covers
independent graph identity,repeated child aliases,self-cycle,mixed scalar
payloads,string/float mutation,date,NIL/logical,nested mutation and
repeated cyclic graph replacement/collection. No original newly closes.

72prior suites PASS(split35+37),including timestamp clone fixture and
intact ains/arrays/array16 gates. Rust104,Linux1177stdout exact,
PE1912PASS22known0FAIL emission only,negative622combined16unchanged
(Linux7/Windows9).Census57/1041unchanged.No performance claim.
ASort2 stays58=42+16 with mandatory original source files.

Parameter/return follow-up on 3f70b838ad0e52d63418531aa3fdab9750f4e9c9:
two additional own MIT fixtures exercise parameter clone/return,mutual
cycles,repeated children,independent invocations,empty graphs,self-cycle
and 37x117 repeated double-clone calls with replaced scalar payloads.
Full updated gate36 = 20 exact fresh-Harbour executions,4 zero final
balances,12 target-profile rejections. Compiler code and SHA unchanged.
The 72-suite and broad regression counts above belong to the preceding
code commit,not a new run for this test-only follow-up. No original newly
closes. Array inequality is intentionally not asserted: a separate fresh
probe found Harbour BASE/1072 for <> whereas current native emitted a
logical result. That mismatch is not fixed by these tests.

    python tests/shared-graph-clone/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-graph-clone-gate

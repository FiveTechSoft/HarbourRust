# Shared array = / <> errors

Own MIT increment on 398f912ea0cbe3d7aa1e5632b168ae8632f8230e.
New commits only,no workflows,push or publication. Harbour programs and
outputs are specifications only. No supplied implementation or cambio.diff
used. Julio Ponce MIT attribution on existing ASort specifications is
unchanged.

Fresh 18-case probe showed arrays under = and <> raise BASE/1071 and
BASE/1072 against arrays and non-NIL scalars,including self comparison.
NIL remains a normal false/true comparison. Exact == remains identity
for two arrays. Previously = and <> incorrectly compared array pointers.

The new local shared helper guards tag16 before the existing dynamic
scalar equality helper. Separate static-string and float boxing routes
are covered too. A temporary string is freed before raising. No changes
to legacy array representation,exact ==,ordering,non-array comparison
errors or other targets are claimed. Error recovery returns the existing
compiler description string,not a Harbour Error object. Uncaught errors
use the existing named exit1 diagnostics,not the Harbour interactive
error dialog. This is error-condition compatibility,not default-handler
or Error-object equivalence.

Gate18:two own sources x5Linux modes = 10 adapted exact executions,
2 strict zero final balances,6 target-profile rejections. Only the oracle
gets an INIT ErrorBlock({|err|Break(err)}) and e:Description rather than
the compiler's caught description string. The adaptations are retained
in evidence. Coverage includes both operand orders,shared child cells,
self/different arrays,integer,float,logical,static and owned temporary
strings,repeated recovery,NIL exceptions and unchanged == identity.

73 prior suites PASS,including updated graph-clone36. Regression execution
was interrupted by the command timeout: complete results were retained,
incomplete directories removed,and the remaining suites rerun. Resume
logs distinguish retained current-compiler results. No missing suite.
Rust104,Linux1177 stdout goldens exact,PE1912PASS22known0FAIL emission
only,negative622combined16 unchanged. Census57/1041 and all diagnostic
hashes unchanged. No new original closure. ASort2 retains58=42+16.

    python tests/shared-array-equality/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-array-equality-gate

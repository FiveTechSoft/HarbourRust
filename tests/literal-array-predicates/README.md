# Constant array literal predicates

Own MIT increment on9a8253427550819ac2b01e654e13a46f41f6300a.
No workflows,push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

HB_ISARRAY/HB_ISNUMERIC accept side-effect-free constant array literals
under the same existing literal predicate used by ValType. Classification
is statically true/false respectively,no payload allocation needed.
HB_ISSTRING already follows ValType and is covered unchanged. Linux
ordinary decimal profile only;macro/threads/other-target fences remain.
This does not admit computed elements or arbitrary calls,activate shared
identity or change variable/indexed legacy paths.

Gate18:two own sources x5modes=10 exact fresh-Harbour executions,2 zero
final balances,6 other-profile rejections. Covers empty,integer,mixed
string/logical/NIL/float,nested,date-bearing literals and repeated calls.
No original newly closes.

63 prior suites PASS including arrays/array16 intact in five Linux modes.
Rust104,Linux1177 stdout goldens exact,PE1912PASS22known0FAIL emission
only. Negatives622 combined16 unchanged (Linux7/Windows9). Census56/1041
with no admission/diagnostic changes. No performance claim. ASort2 stays
58=own42+originals16 with mandatory original files.

    python tests/literal-array-predicates/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/literal-array-predicates-gate

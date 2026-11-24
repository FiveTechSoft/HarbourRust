# Len of a constant array literal

Own MIT increment on cdb20f58770e95bb5d7dfc1ec0c5b9b6fb8f501a.
No workflows,push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

Len of a side-effect-free constant array literal returns its outer element
count without allocating the payload. The same existing literal predicate
as ValType defines this boundary,including empty,nested,mixed and date
constant elements. Only ordinary Linux decimal profile; no computed
elements,arbitrary calls,macro/threads/other-target expansion or change to
variable/temporary ownership paths. No runtime helper.

Gate18:two own sources x5modes=10 exact fresh-Harbour executions,2 zero
final balances,6 other-profile rejections. Covers empty,integer,mixed
string/logical/NIL/float,nested,date-bearing literals,repeated counts and
distinction between outer count and nested length. No original closes.

64 prior suites PASS including arrays/array16 intact in five Linux modes.
Rust104,Linux1177 stdout goldens exact,PE1912PASS22known0FAIL emission
only. Negatives622 combined16 unchanged (Linux7/Windows9). Census56/1041
with no admission or diagnostic changes. No performance claim. ASort2
remains58=own42+originals16 with mandatory originals.

    python tests/literal-array-len/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/literal-array-len-gate

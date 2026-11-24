# SET DATE FORMAT command spelling

Own MIT increment on e8b6d40806004cbbde482685f0df90a8f1889d4e.
No workflows, push or publication. Harbour programs and observed output
are specifications only. No Harbour implementation or cambio.diff used.
Thanks to Julio Ponce for the independent MIT ASort examples used by the
unchanged mandatory original regression gate.

SET DATE FORMAT [TO] expression now parses to the existing checked
Set(4,expression) call. This is a parser change, not new mask semantics.
The discarded previous-mask result keeps the ordinary owned-string
cleanup. Literal and plain string-variable masks keep their current
validation, profile and macro restrictions. SET DATE BRITISH and the
other existing named layouts keep their old route.

Gate 28: two own fixtures in five Linux modes byte-exact against freshly
built Harbour (10), two strict final heap balances zero (2), six profile
rejections (6), seven syntax/type/scope rejections (7), and three runtime
named limits (3). Runtime limits are explicit hbc diagnostics, not
Harbour error compatibility. The fixtures cover optional TO, parenthesized
literal, century changes, empty-date output, CToD interpretation, mask
case, repeated borrowed inputs and discarded owned results (151 rounds).

84 prior suites PASS, including mandatory ASort2 58 = 42 own + 16 Julio
original executions. Rust 104 PASS. Linux stdout goldens 1177 exact.
PE emission only: 1912 PASS, 22 known mismatches, zero new failures.
622 negative cases retain the same 16 combined mismatches. Census remains
57 compile admissions / 1041 sources, no new original execution closure.
One rejection diagnostic changes: intact tests/transfrm.prg now reaches
line 242 rather than stopping on SET DATE FORMAT at line 63. It remains
rejected and is not claimed working. No speed or non-Linux runtime claim.

An initial parallel regression run exceeded the execution window. Only
completed PASS logs were retained as results; unfinished suites were
rerun in bounded batches. No incomplete run was counted as PASS.

    python tests/set-date-command/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/date-command-gate

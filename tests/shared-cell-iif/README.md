# Mixed IIF with a borrowed shared cell

Own MIT increment on9584fdfdb1b6cd48855d7954f74666056c636cb7.
No workflows,push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

The existing mixed scalar IIF machinery accepts a one-level borrowed
cell read of an already-selected local shared array as a Dyn arm. It
evaluates only the selected branch,screens the selected dynamic tag as a
scalar,clones borrowed string/float payloads and releases the owned result
at the existing approved consumers. No array/date/object Dyn arms,no
arbitrary calls or deep paths,no identity activation or new profile.
Existing mixed-IIF consumer restrictions remain. No runtime helper added.

Gate18:two own fixtures x5modes=10 exact fresh-Harbour executions,2 zero
final balances,6 profile rejections. Covers both orientations,live/dead
branches,integer/string conversion,borrowed heap-float branch,repeated
owned temporary cleanup and unchanged source. An exploratory HB_NToS of
a float cell printed padding unlike Harbour;this preexisting consumer
gap is excluded,not counted as a pass. The direct float IIF branch is
measured separately.

Original ains now COMPILES but DOES NOT execute successfully:the intact
original exits1 on its first AIns because that existing mutator expects
legacy tag8 rather than shared tag16. Its oracle/native evidence is
included under exploratory original evidence. No original is closed.
Census57/1041,exactly one compile admission ains,not runtime compatibility.

67 prior suites PASS,Rust104,Linux1177 stdout goldens exact,
PE1912PASS22known0FAIL emission only. Negatives622 combined16 unchanged
(Linux7/Windows9).No performance claim. ASort2 stays58=42+16,mandatory
originals. Regression wrapper reached its outer time limit after all67
suites finished;each per-suite result and completed aggregate is retained.

    python tests/shared-cell-iif/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-cell-iif-gate

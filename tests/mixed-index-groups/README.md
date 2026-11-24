# Mixed comma/chained index groups

Own MIT increment on 839516d1513dfaa177f1708239a6ca2f7ff73c96.
No workflows, push or publication. Harbour syntax and fresh outputs are
specifications only. No reference implementation or supplied diff used.
Julio Ponce MIT attribution remains on unchanged ASort specifications.

Mixed paths such as a[i,j][k,l], a[i][j,k], a[i,j][k] now normalize to the
existing comma path nodes, without duplicating any index expression.
Only paths with multiple groups AND a top-level comma are normalized.
Nested brackets/parentheses/braces retain their own commas and string
contents are already tokenized, never textually replaced. Existing pure
chains and single comma groups retain their old paths and diagnostics.
The existing depth4, types, bounds and compound-update limits remain.

Tagged nested literals with depth3/4 stores now activate the same shared
identity route as depth2 stores. This handles noninteger leaves/aliasing,
not a new object model. The existing non-Linux/macro/class/external fences
on shared storage remain. No array-producing function lvalues, cell
increments, arbitrary depth or new compound arithmetic are admitted.

Gate20: exact10 Harbour executions in five Linux modes each for two own
fixtures, balance0 twice, six profile rejections and two named limits.
Covers mixed reads/writes through depth4, aliases and mixed scalar leaves,
right-side/index side-effect order, allocation and untouched string text.
No new original is closed. Original arrays.prg/array16.prg diagnostics
advance to later cell-increment syntax; both remain rejected.

Census54/1041 admissions unchanged, only those two diagnostics change.
51 prior suites PASS, Rust104, Linux1177 stdout golden rows exact,
PE1912PASS22known0FAIL emission only. Neg622 combined15 unchanged,
Linux6/Windows9. No performance claim or wider target execution claim.

    python tests/mixed-index-groups/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/mixed-index-gate

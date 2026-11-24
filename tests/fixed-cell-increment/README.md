# Local fixed integer-cell pre/post increment

Own MIT increment on cb0be0b46f78ba1fdfdf143f3ab79c2015602591.
No workflows, push or publication. Fresh Harbour outputs are specifications
only; no Harbour implementation or supplied diff used. Julio Ponce MIT
credit remains on unchanged ASort specifications.

Adds expression pre/post ++/-- on a single-level fixed integer LOCAL array
cell, ordinary Linux without macros. The index evaluates once, bounds are
checked before reading/writing, and prefix/postfix returns new/old value.
Out-of-range variable indexes use the existing native bounds error.
Overflow cannot silently wrap the cell: it follows the existing checked
integer error, or type error outside that mode. This is a named runtime
boundary, not Harbour's integer-to-double promotion or its error handler.
No parameter, module STATIC, shared/dynamic/string/nested array or new
statement-lvalue form is admitted. Compiler identity is unspellable.

Gate36:15 exact executions against fresh Harbour (three fixtures x5modes),
three balances0, nine target rejections, seven limits, and two native
runtime bounds errors (not byte comparisons to Harbour default errors).
Includes unchanged historical negative t897, now deliberately accepted on
Linux and exact-oracle tested, not silently removed from the manifest.
Index side effects, call arguments, postfix old value, prefix new value
and repeated loops are covered. Windows retains old diagnostic substring.

No intact original newly closes. arrays/array16 advance from flat cell
increment to a later nested cell increment, codebloc reaches a later
arithmetic rejection. Census54/1041 unchanged admissions; only these three
diagnostics change. 52 prior suites PASS, Rust104, Linux1177 stdout golden
rows exact, PE1912PASS22known0FAIL emission only. Neg622 combined16:Linux7
(previous6 plus intentional t897),Windows9 CurDir unchanged. No speed claim.

    python tests/fixed-cell-increment/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/fixed-cell-inc-gate

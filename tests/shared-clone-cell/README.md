# AClone of one shared child cell

Own MIT increment on 1efc528e9a7f0d590ee9efa17eeec1c7d41e342c.
No workflows,push or publication. Harbour sources/outputs are specs only.
No supplied implementation or cambio.diff used. Existing Julio Ponce MIT
attribution on ASort specifications remains unchanged.

AClone accepts a one-level indexed cell rooted in an already shared local
or parameter. The existing indexed read evaluates/bounds-checks the index,
then a tag16 value enters the graph clone;non-array cells return NIL.
A fresh scalar Harbour probe confirmed AClone(integer/string/NIL) returns
NIL,so an exploratory type-error guard was replaced before final testing.
The scalar behavior is supported here only through the newly admitted
shared-cell argument,not arbitrary scalar expressions. Graph clone helper
unchanged. Discovery propagates the result through locals,direct returns
and direct call arguments. Multi-level AClone arguments and arbitrary
expressions are not added. No new identity activation,legacy-array changes
or target expansion.

Gate18=10 exact fresh-Harbour executions(two own sources x5Linux modes),
2 strict final balances0,6 profile rejections. Covers child identity and
mutation isolation,child self-cycle,direct parameter return/call argument,
scalar string/float/NIL cells and37x117 cyclic child replacements.
No ErrorBlock/source adaptation. No newly closed original. Graph helper
remains recursive with linear-map lookup,no new depth/performance claim.

80 prior suites PASS(35+45),Rust104,Linux1177stdout goldens exact,
PE1912PASS22known0FAIL emission only,negative622combined16unchanged.
Census57/1041 and diagnostic hashes unchanged. ASort2 stays58=42+16.
All final evidence uses compiler f4946502c26be85431d7ffca982cab44b8dbd18b5ab1e6eabb50c91e7a695ec5.
An earlier exploratory build's results are not used for these counts.

Test-only follow-up on 3c73a5ba0cd67d12f9937a8dad14d7daa74f91af:
scalars-index.prg adds integer,logical,date,string,float and NIL cell
fallbacks,117 repeated rounds and a STATIC counter proving one evaluation
of an effectful index. Updated full gate27=15 exact fresh-Harbour
executions,3 zero balances,9 profile rejections. Compiler SHA unchanged.
Broad regression numbers above belong to the code commit and were not
rerun for this fixture-only follow-up. No newly closed original.

    python tests/shared-clone-cell/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-clone-cell-gate

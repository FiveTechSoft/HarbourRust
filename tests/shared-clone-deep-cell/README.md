# AClone of deeper shared cells

Own MIT increment on cdb848272aa2bce3fc0be2ce37ed15df5e56550f.
No workflows,push or publication. Harbour programs/outputs are specs only.
No supplied implementation or cambio.diff used. Existing Julio Ponce MIT
attribution on ASort specifications remains unchanged.

Extends the existing shared child-cell AClone path to indexed argument
expressions at depths two through four,using the same borrowed indexed
read and graph clone. The existing index helper evaluates indices once
left-to-right,checks each parent tag and bounds,and leaves the final pair.
Final array cells clone;final scalars return NIL. Discovery propagates
through locals,direct returns and direct call arguments. A fresh unadapted
Harbour probe confirmed identity/mutation isolation before implementation.
No arbitrary argument expression,new identity activation,legacy-array
change or other-target support. Runtime graph helper unchanged,including
recursive traversal and linear-map limits. More than four index levels
are not added.

Gate18=10 exact fresh-Harbour executions(two own sources x5Linux modes),
2 strict final balances0,6 profile rejections. Depths2/3/4,independent
identity,scalar fallback,effectful index order,direct parameter return and
call arguments,self-cyclic child and37x117 replacements are covered.
No ErrorBlock/source adaptation. No newly closed original.

81 prior suites PASS(35+46),including shared-clone-cell27,Rust104,
Linux1177stdout goldens exact,PE1912PASS22known0FAIL emission only,
negative622combined16unchanged. Census57/1041 and diagnostic hashes
unchanged. ASort2 stays58=42+16 with mandatory original source files.
Verified duplicate extracted package trees were removed after comparing
every file with their retained archives;archives and raw evidence remain.

Test-only follow-up on 13ee8f3e7a8b67800dbe79f29685a245a1b41428:
errors.prg repeats bounds failures at levels1..4 and a non-array parent
failure,then verifies the source remains accessible. Only this fixture's
oracle gets INIT ErrorBlock/Break;it compares recovery counts and surviving
state,not error objects/descriptions/default handlers. Fresh probe showed
Harbour1132 Bound error and1068 Argument error;the compiler's existing
caught strings differ,so no description equivalence is claimed here.
Full updated gate27 = 10 unadapted exact executions +5 adapted recovery-
count executions +3 zero balances +9 profile rejections. Compiler SHA
unchanged. Broad regressions above were not rerun for this test-only
follow-up. No newly closed original.

    python tests/shared-clone-deep-cell/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-clone-deep-cell-gate

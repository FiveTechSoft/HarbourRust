# One-level shared float numeric predicate

Own MIT increment on869e5c0a86f96fbf58a8a8e1a93d2009471d4730.
No workflows,push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

HB_ISNUMERIC on a one-level cell of an already-selected local shared array
now includes heap-float tag5,like the measured depth2..4 predicates and
Dyn variable route. It uses the existing checked borrowed read,with no
allocation or payload cloning. HB_ISARRAY is measured on that same route.
Legacy unique/module-only roots and other profiles are unchanged.

Gate18:two own fixtures x5modes=10 exact fresh-Harbour executions,2 zero
final balances,6 profile rejections. Covers integer,float,string,logical,
NIL,date,array child,mixed IIF selection and repeated predicates.

Correction to earlier exploratory diagnosis:the padded float in the
shared-cell-iif experiment was NOT an HB_NToS formatting bug. The
one-level HB_ISNUMERIC(float-cell) returned false,selecting the raw
numeric IIF arm. Direct HB_NToS produced trimmed19.25 correctly. This
fixture now checks the predicate and bracketed IIF result plus length.
No change to HB_NToS was needed. No original newly closes.

71 prior suites PASS after one infrastructure rerun:the initial shared-
afill runner passed the Julio source directory instead of Harbour and
failed missing-source validation;rerun with the correct root passes27.
Rust104,Linux1177stdout exact,PE1912PASS22known0FAIL emission only,
negative622combined16 unchanged(Linux7/Windows9).Census57/1041unchanged.
No performance claim. ASort2 stays58=42+16,mandatory original sources.

    python tests/shared-float-predicate/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-float-predicate-gate

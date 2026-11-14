# hb_HHasKey returns a logical value

After main 29d3c16, the public type of `hb_HHasKey(hash, key)` is now logical (`.T.`/`.F.`),
matching Harbour, rather than the historical integer flag surface (`1`/`0`).
Both semantic analysis and code-generation type inference agree on Bool.
The existing leaf runtime still returns canonical internal 0/1 bits, and
key/hash borrowing and owned-key cleanup are unchanged.

This fixes direct output, logical conditions, local copies, logical operators,
function return and ValType (`L`). Expressions which used its previous
integer surface, such as `hb_HHasKey(h,"a")+1`, now reject as noninteger
arithmetic. Use logical expressions, not numeric dependence on a predicate.
Other historical integer-returning flag APIs are not changed by this patch.

Validation: a fresh source fixture matches real Harbour 3.2.1dev output,
empty stderr and exit 0. The earlier I64-to-Bool candidate passed Linux instrumented 1728/1728 across
bounded runs: 1726 existing cases plus 2 new. Thirteen historical expected
outputs change only their membership results from padded 1/0 to .T./.F.;
integer results and final hb_memcheck 0 values remain unchanged.
That candidate also passed twenty-eight generated Windows PE runs under Wine 11 (14 sources, normal
and instrumented), matching expected output with empty stderr/exit 0.
No new native-Windows run or complete normal-mode manifest is claimed.
Historical battery/history documents retain their original dated records;
this note supersedes only their old HHasKey integer-rendering limitation.

This test/document follow-up does not change compiler code or rebuild tracked or released compiler snapshots.
The ARM research frontend hash guards need a deliberate rebase after this
source change; they should not be bypassed. No ARM admission is added.

Follow-up against main c276530: the source fix (29d3c16) and all
membership-output expectations (9009834) are already integrated.
This change adds the logical fixtures and this note, and preserves
the current source normalization and PE stack full-commit fix unchanged.
Fresh focused execution against c276530 is recorded in the commit.

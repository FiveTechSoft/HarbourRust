# Constant one-dimensional Array in shared context

Own MIT increment on 4dee9615f81fce5245c231a9f051ad3ea58ea818.
No workflows, push or publication. Fresh Harbour outputs are specifications
only, no implementation or supplied diff used. Julio Ponce MIT attribution
remains on the unchanged ASort specifications.

When shared-array identity is already active, Array(n) with a compile-time
integer n in0..10000 builds an empty registered shared object and resizes
it with the existing NIL-fill helper. Plain Array outside shared context
keeps its old representation. Constructors do NOT activate shared identity
by themselves. Computed/negative/over10000/multidimensional dimensions in
shared context retain the named capability rejection. No arbitrary dynamic
constructor dimensions or nested cell increments are added.

Gate22: exact10 fresh-Harbour executions (two fixtures x5modes), balances0x2,
profile rejections6 and four named limits. Covers capacity10000, NIL cells,
string/float writes, aliases, resize, AAdd, zero-size allocation and repeated
rebuild/release. The shared collector remains responsible for old objects.

Four old negative fixtures are explicitly promoted unchanged, not erased:
timestamp-phase3 constant-constructor, array-cycle-entry constant-constructor,
asort-phase2 constant-constructor and nested-array-entry constructor. Each
now has exact4 Linux executions and balance0. The first three reject other
targets; the last already compiles on their legacy unique-array route and
is recorded as emission-only, NOT shared-array support or execution there.
Their gates grow respectively51->58,59->66,51->58,51->58. This replaces the
old all-constructors-prohibited boundary with the bounded constant rule.

No intact original newly closes. Census54/1041 and diagnostics unchanged.
53 prior suites PASS, Rust104, Linux1177 stdout golden rows exact,
PE1912PASS22known0FAIL emission only. Neg622 unchanged combined16,
Linux7/Windows9. No performance claim. First regression batch timed out
and all missing17/18 suites were rerun under separate output prefixes.

    python tests/shared-constant-array/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-constant-array-gate

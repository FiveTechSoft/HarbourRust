# Shared integer-cell pre/post increment

Own MIT increment on 54422c3c7a86409f0b58563c473b3e5a2afa0412.
No workflows, push or publication. Fresh Harbour outputs are specifications
only, no implementation or supplied diff used. Julio Ponce MIT attribution
remains on unchanged ASort specifications.

Pre/post ++/-- accepts paths of1..4 levels through an already-selected
local shared array. Each integer index runs once left-to-right, then the
root and each level are checked, matching the existing shared read order.
Every intermediate cell must be a shared array. Final cell must be one
of the two native integer tags. Prefix returns new/postfix old value.
Aliasing sees the store immediately. No allocator/call occurs during the
cell mutation. Noninteger cells and overflow take the existing native type
error, not Harbour default-handler parity or integer-to-double promotion.

Roots must be local shared storage, not module bindings or parameters.
Indexes must be statically integer and not mention the root. Existing
non-Linux/macro fences remain. Legacy nested unique arrays still reject;
this does not activate shared identity or reinterpret every nested array.

Gate24: exact10 Harbour executions (two fixtures x5modes), two balances0,
six profile rejections, four compile limits, two native runtime errors.
Fixtures cover four-level mixed/chained syntax, aliases, pre/post direction,
untouched strings, repeated updates and nested function scopes. Error cases
are bounds/noninteger-cell checks, not byte comparisons to Harbour errors.

No original newly closes. arrays/array16 pass their cell-increment syntax
but then reject a prior ValType literal shape once type checking starts.
Census54/1041 unchanged admissions; only those two diagnostics change.
54 prior suites PASS, Rust104, Linux1177 stdout golden rows exact,
PE1912PASS22known0FAIL emission only. Neg622 unchanged combined16,
Linux7/Windows9. No performance claim.

    python tests/shared-cell-increment/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-cell-inc-gate

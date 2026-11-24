# ATail of indexed shared cells

Own MIT increment on91e88be98e61bc1389c40ec67507d685ab6fbea2.
No workflows,push or publication. Fresh Harbour output is specification.
No supplied implementation or cambio.diff used. Julio Ponce's MIT ASort
examples remain credited regression specifications.

ATail accepts bounded indexed expressions rooted in an already selected
shared variable,depths1..4. The existing borrowed indexed reader evaluates
each index once and checks intermediate tags/bounds. Final non-array or
empty array yields NIL. Otherwise the last cell's payload escapes through
the existing clone helper,so owned string/float results survive mutation;
array results preserve shared identity. No arbitrary call-result source,
new shared entry trigger,lvalue change or RC-policy expansion is added.

Gate18:two own fixtures,five exact Harbour modes each,two strict final
zero balances,six profile rejections.117rounds cover string ownership,
integer,float,logical,NIL,array identity,empty array,non-array final cells,
index effects and all four supported indexed depths. Intermediate error
wording equivalence is not claimed;the reader is unchanged.

90prior suites complete,ASort2mandatory58=42own+16Julio,Rust104,
Linux1177stdoutgoldens exact,PE1912PASS22known0FAIL emission-only.
Negative622 retain16combined mismatches. Census57/1041 and all diagnostic
hashes identical. Original calls keeps40exact/6zero/2knownDELTA2;object
lifetime debt remains open. No newly closed original or speed claim.

    python tests/shared-tail-cell/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/tail-cell

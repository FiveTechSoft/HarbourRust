# ASort phase12: bounded default Date/timestamp ordering

Own MIT on126b32247b4462e738ecf51597b31aa9d294a276 (phase11 delivered).
Julio Ponce's MIT e19 temporal cases and fresh Harbour output are
specifications only,no copied implementation or cambio.diff.
No workflows,push or publication. e19 as a whole is NOT closed.

Timestamp-enabled programs route default shared ASort through the existing
phase7 top-down merge with an internal comparator. The payload preflight
also accepts tag17 there. Two timestamps compare full packed values;
Date/timestamp pairs compare date portions only. Other types retain the
previous family rank,with Date and timestamp in the same family. Ordinary
Date/Date compares scalar dates. No expression-operator changes and no
generic callback coercion claim.

Mixed temporal comparison is nontransitive:two timestamps on the same day
can compare differently while both compare equal to a Date of that day.
Therefore the merge decision sequence matters. Fresh Harbour same-day
fixtures pin that behavior;insertion sorting is not substituted. No heap
temporary;the internal comparison calls existing timestamp/date helpers.

Gate40:4own+a04,20exact executions across4Linux modes,5strict final
balances,15profile rejections. Fresh Harbour covers mixed temporal order,
same-day decisions,empty values,all scalar families and113subrange sorts.
DELTA0 requires exact stdout,rc0,empty stderr and a measured marker.

ASort1..11:88,51,32,37,40,56,50,42,33,27,24. Timestamp1..9,B1/B2,A1/A2,
cycle59,nested51,Rust99 pass. Linux1176exact plus identical inherited
ctod_order_epoch failure;negatives622 retain13known mismatches unchanged.
PE emission1912PASS22known0FAIL,no PE runtime claim. Censo48/1041 unchanged.
c02,e19 captures/general helpers,e20 remain open.

    python tests/asort-phase12/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort12-check

Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence.
No binaries,objects or disposable assembly.

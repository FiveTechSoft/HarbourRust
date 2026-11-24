# ASort phase17: empty-array prefix and e20 internal stress

Own MIT incremental on2f552951252d4cc17f21f0ad9f2357c2c0a2c022.
Julio Ponce's MIT programs and Harbour outputs are specifications only.
No implementation or cambio.diff used. No workflows,push or publication.

The bounded nested-counter proof also admits a fresh empty-array
constructor before the inner FOR. It cannot invoke user code or transfer
control. No calls,nonempty builders or control flow are newly admitted.
EXIT,LOOP and IF-EXIT after that constructor still reject. Fresh Harbour
runs show ValType(k)=U on all three rejected own fixtures. Corrected
phase15's earlier negative fixtures remain rejected too.

Gate22: own nested-empty exact against fresh Harbour in5Linux modes,
original e20 internal assertions in5modes,2strict final DELTA0 checks,
6profile rejections and4named limits. e20 is run unchanged: its counters
check300recoveries and total5900 per Exercise,and pending0 after repeated
Exercise. Native,external assembler,no VAS,no escape and no-prune pass.
Its strict final balance also requires matching stdout,rc0,empty stderr
and an actual measured marker. SHA of input e20 is in results.json.

Important: e20 is NOT a fresh Harbour differential pass. Standard Harbour
rejects its TRY/CATCH spelling and lacks its custom hb_memcheck function.
Its original source now passes its own internal assertions and our strict
final ownership measurement. Supplied e20 assertions are not independent
proof of exact callback trace or default error-handler equivalence.
c02 remains open,so the whole ASort collection is not closed.

ASort1..16,timestamp1..9,B1/B2,A1/A2,cycle59,nested51,Rust99 pass.
Linux1176exact plus identical inherited ctod_order_epoch failure.622
negative cases retain the same13known mismatches. PE emission1912PASS,
22known,0FAIL,no PE runtime claim. Censo48/1041 unchanged. All three
JSON baselines compared equal against phase16,not just equal counts.

    python tests/asort-phase17/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort17-check

Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence.
No binaries,objects or disposable assembly.

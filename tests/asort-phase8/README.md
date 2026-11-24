# ASort phase8: bounded row-key callbacks

Own MIT on36394826ee2284eb75f43c80e542b5ac48679b31 (phase7 delivered).
Julio Ponce's MIT a06 and Harbour output are specifications only,no copied
implementation or cambio.diff. No workflows,push or publication.

Callback operands may be parameter[k] for positive literal integer k.
Parameters remain borrowed tagged cells;within analysis/codegen of that
block their root lookup uses the existing A2 tag16 guard and bounds check,
not the legacy unique-array tag8 route. The scoped parameter marker is
restored after checking/emitting each block. Index expressions,captures,
mutation and arbitrary helper calls remain outside the callback profile.
Shared array discovery also recognizes literal assignment after LOCAL
without initializer. Pure text literals keep the previous entry selection.

Sorting uses the unchanged phase7 merge helper. Strict key comparisons
preserve equal-key row order;non-strict comparisons follow measured
right-selection decisions and need not preserve equal-key input order.
Whole row-reference cells rotate;child ownership and aliases stay intact.
No general callback,mixed Date/timestamp or comparison-coercion claim.

Gate42:4own+a06,20exact executions across4Linux modes,5strict final
balances,15profile rejections,2named dynamic-index limits. Fresh Harbour
covers strict/non-strict duplicate keys,aliases across rebuild,subranges,
text keys and97double sorts with int/float keys. DELTA0 requires exact
stdout,rc0,empty stderr and an actual measured marker.

ASort1..7:88,51,32,37,40,56,50. Timestamp1..9,B1/B2,A1/A2,cycle59,nested51,
Rust99 pass. Linux1176exact plus identical inherited ctod_order_epoch
failure;negatives622 retain13known mismatches unchanged. PE emission
1912PASS22known0FAIL,no PE runtime claim. Censo48/1041 unchanged.
a07,a08,c02,e18..20 remain open.

    python tests/asort-phase8/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort8-check

Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence.
No binaries,objects or disposable assembly.

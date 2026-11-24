# ASort phase15: bounded nested counter and indexed-cell LEN

Own MIT on75349690012ac4d4ad855a27e3c6352bd6689f3f (phase14 delivered).
Julio Ponce's MIT e20 shapes and fresh Harbour output are specifications
only,no copied implementation or cambio.diff. No workflows,push/publication.
e20 as a whole is NOT closed.

The bare-local FOR-counter proof admits one nested counter under an outer
FOR with literal bounds proven to run at least once,in active A2 only.
The inner FOR must be the first mention of that local in the outer body;
its bounds cannot read the uninitialized counter. Earlier reads retain
the named rejection. This proof types the counter I64 consistently in
checker,layout and emission;there is no runtime Dyn counter conversion.

Len of double-indexed A2 cell dispatches through existing generic tagged
LEN:shared array -> object length,string -> byte length,other -> type error.
Indices use existing A2 guards/bounds. No unique-array path is widened.

Gate20:2own,10exact executions across5Linux modes(including --no-prune),
2strict final balances,6profile rejections,2named limits. Fresh Harbour
covers nested-counter final state,21appends,and string/nested-array cell
lengths after row sort. The added mutator limit changes a row but RETURNS
a scalar comparison of row cells,so rejection isolates the forbidden write
rather than an invalid array comparison. DELTA0 requires exact stdout,rc0,
empty stderr and a measured marker.

ASort1..14 pass. Timestamp1..9,B1/B2,A1/A2,cycle59,nested51,Rust99 pass.
Linux1176exact plus identical inherited ctod_order_epoch failure;negatives
622 retain13known mismatches unchanged. PE emission1912PASS22known0FAIL,
no PE runtime claim. Censo48/1041 unchanged. c02,e20 remain open;original
e20 now reaches its arithmetic callback limit x+1<y. Its hb_memcheck and
error-handler semantics are not claimed by these fixtures.

    python tests/asort-phase15/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort15-check

Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence.
No binaries,objects or disposable assembly.

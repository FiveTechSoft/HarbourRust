# ASort phase13: read-only captured row sorting, e19

Own MIT ondd370d42c166a5c1a5e84634ad9f695c05914921 (corrected phase12).
Julio Ponce's MIT e19 and fresh Harbour output are specifications only,
no copied implementation or cambio.diff. No workflows,push or publication.

Shared direct callback comparisons admit read-only trees:parameter reads,
scalar literals,array reads,comparisons,iif,and structurally pure helpers.
A pure helper has exactly one RETURN containing only its own parameter
reads,literals,comparisons,array reads and iif. Calls to user code are not
recursive through this proof. Ordinary type checking still checks arity,
return types,index types and call ABI. Array-reader helper parameters use
existing A2 guards. Callback-local captures are read-only integer/logical
values;writes,computed side effects and arbitrary helper calls stay closed.

Literal arrays appended through AAdd in active A2 use the existing fresh
descriptor builder. No unique-array representation is stored. Captured
slots reserve at least16bytes because the existing copy loop copies a
pair;this prevents an8byte logical capture from overwriting the parked
owner context before the next capture. Other block capture rules remain.

Gate29:2own+full e19,15exact executions across5Linux modes(including
--no-prune),3strict final balances,9profile rejections,2named write limits.
Fresh Harbour e19 bytes include trailing-space trimming and terminal
wrapping without normalization. Own fixtures cover59double row sorts,
logical/integer captures,float keys,pure reader/compare helpers and113
literal nested appends. DELTA0 requires exact stdout,rc0,empty stderr and
an actual measured marker. Old limit-capture fixtures in phases7/8 now
run against Harbour rather than being dropped;their gates become57/49.

ASort1..12 pass:88,51,32,37,40,56,57,49,33,27,24,63. Timestamp1..9,B1/B2,
A1/A2,cycle59,nested51,Rust99 pass. Linux1176exact plus identical inherited
ctod_order_epoch failure;negatives622 retain13known mismatches unchanged.
PE emission1912PASS22known0FAIL,no PE runtime claim. Censo48/1041 unchanged.
c02,e20 remain open. General mutating/throwing callback support not claimed.

    python tests/asort-phase13/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort13-check

Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence.
No binaries,objects or disposable assembly.

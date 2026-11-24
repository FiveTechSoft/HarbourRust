# ASort phase4: result observers and ignored scalar arguments

Own MIT on63746d9bdaac3f8371f34b58d1573d2b4f10f788 (phase3 delivered).
Julio Ponce's MIT a09 and Harbour outputs are specifications only,no copied
implementation or diff. No workflows,push or publication.

Ordinary Linux shared ASort result can be observed with Len/ValType;the
existing shared result length path is reused. Fourth scalar/NIL argument
is evaluated and ignored (no callback). Scalar/nonarray first arguments
return NIL after all admitted scalar arguments evaluate. Owned text
arguments are released,not leaked. Dyn unknown first arguments,general
callback values and other payload families remain outside this phase.
Shared entry also recognizes a fourth non-block argument;literal blocks
stay rejected. Existing nonshared sorting paths remain unchanged.

Gate37:four own+a09,five sources x4Linux modes=20exact,five strict balances,
12non-Linux rejections. Pure scalar noarray source has no profile-rejection
claim. Includes aliases,result identity,317owned text argument lifetimes,
157exceptions before sort;the array remains unsorted on those throws.
Strict balance requires exact stdout,rc0,empty stderr.

    python tests/asort-phase4/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort4-check

Regressions:ASort1=67,2=51,3=32,timestamp1..9,B1/B2,A1/A2,cycle59,nested51,
Rust99. Linux1176exact+inherited ctod_order_epoch failure unchanged;
negatives622 including13known unchanged;PE emission1912PASS22known0FAIL.
Census48/1041 unchanged. No Windows/Mac runtime claim. Mixed,float,callback,
row sorting and e18..20 remain open. Reduced bundle/patch,LEEME,attribution,
manifest,compilerSHA,raw logs,no binary/object/disposable assembly.

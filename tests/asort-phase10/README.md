# ASort phase10: bounded persistent-string trace helper

Own MIT onf6355ff1ab1d3685b56c6819fc9be7f7f990caff (phase9 delivered).
Julio Ponce's MIT a07 and Harbour output are specifications only,no copied
implementation or cambio.diff. No workflows,push or publication.

A shared direct callback may call one structurally checked helper with two
parameter arguments. The helper has exactly one assignment to a module
STATIC owned string followed by RETURN comparison of its two parameters.
The assignment tree contains only that string,constant text,plus,and
hb_ntos of a parameter. No loops,mutators,extra effects or arbitrary calls.
The checker still verifies helper types and ordinary function-call ABI.

Module STATIC expression safety admits plus trees of variables/literals
and hb_ntos of one variable(other than the slot itself) or integer literal.
This whitelist allows pure formatting beside a borrowed persistent string;
it does not relax the general call/mutation guard. Existing concat owns
its new result before replacing the persistent slot. No runtime helper
change and no temporary ownership outside ordinary string/function rules.

Gate27:2own+a07,12exact executions across4Linux modes,3strict final
balances,9profile rejections,3named effect/capture limits. Fresh Harbour
traces for n2..9 and151subrange repetitions match byte for byte. DELTA0
requires exact stdout,rc0,empty stderr and an actual measured marker.

ASort1..9:88,51,32,37,40,56,50,42,33. Timestamp1..9,B1/B2,A1/A2,cycle59,
nested51,Rust99 pass. Linux1176exact plus identical inherited
ctod_order_epoch failure;negatives622 retain13known mismatches unchanged.
PE emission1912PASS22known0FAIL,no PE runtime claim. Censo48/1041 unchanged.
c02,e18..20 remain open. General helper callbacks/captures are not claimed.

    python tests/asort-phase10/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort10-check

Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence.
No binaries,objects or disposable assembly.

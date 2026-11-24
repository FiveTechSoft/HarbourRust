# ASort phase9: literal nonlogical callback results

Own MIT on678dcad3f36fcd424eb4728aa4545f703ee4e5a3 (phase8 delivered).
Julio Ponce's MIT a08 and Harbour output are specifications only,no copied
implementation or cambio.diff. No workflows,push or publication.

Shared direct callbacks may take zero,one or two parameters and end in
literal NIL,integer or string as well as the existing comparison/logical
tail. Only two-parameter callbacks may contain a comparison. Optional
QOut traces retain the previous atom-only restriction.

Measured Harbour decision:literal NIL,string(including empty) and nonzero
integer choose the right run;integer0 chooses left. This is deliberately
not an assertion about general logical conversion. These constant tails
compile directly to the measured branch decision,with no temporary string
allocation. Calls,computed values,floats and containers as return values
remain outside this stage. Only checked shared-ASort block IDs take this
codegen route;ordinary codeblocks retain their prior behavior.

Gate33:3own+a08,16exact executions across4Linux modes,4strict final
balances,12profile rejections,1named call-result limit. Fresh Harbour
covers empty/nonempty strings,negative/zero/positive integers,NIL,trace
sequence,subrange,mixed-cell no-op behavior and211repeated calls. DELTA0
requires exact stdout,rc0,empty stderr and an actual measured marker.

ASort1..8:88,51,32,37,40,56,50,42. Timestamp1..9,B1/B2,A1/A2,cycle59,nested51,
Rust99 pass. Linux1176exact plus identical inherited ctod_order_epoch
failure;negatives622 retain13known mismatches unchanged. PE emission
1912PASS22known0FAIL,no PE runtime claim. Censo48/1041 unchanged.
a07,c02,e18..20 remain open. Full callback support is not claimed.

    python tests/asort-phase9/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort9-check

Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence.
No binaries,objects or disposable assembly.

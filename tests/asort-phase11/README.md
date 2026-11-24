# ASort phase11: e18 and shared date-cell DToS

Own MIT on6692794a8e962f0e85d2a7cb2c3522e03009e213 (phase10 delivered).
Julio Ponce's MIT e18 and Harbour output are specifications only,no copied
implementation or cambio.diff. No workflows,push or publication.

DToS accepts a Dyn cell only in the active shared-local A2 profile. Runtime
guards tag11 before extracting the date payload and calling the existing
formatter. Other tags raise the existing type error. Static date behavior
and profiles without A2 stay unchanged. No date/timestamp coercion claim.

Gate24:2own+full e18,12exact executions across4Linux modes,3strict final
balances,9profile rejections. Fresh Harbour e18 output is compared byte
for byte,including GTSTD80 wrapping,with no normalization. Own tests cover
empty/valid dates and guarded mixed-array reads. DELTA0 requires exact
stdout,rc0,empty stderr and an actual measured marker.

ASort1..10:88,51,32,37,40,56,50,42,33,27. Timestamp1..9,B1/B2,A1/A2,cycle59,
nested51,Rust99 pass. Linux1176exact plus identical inherited
ctod_order_epoch failure;negatives622 retain13known mismatches unchanged.
PE emission1912PASS22known0FAIL,no PE runtime claim. Censo48/1041 unchanged.
c02,e19,e20 remain open;full ASort callback support is not claimed.

    python tests/asort-phase11/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort11-check

Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence.
No binaries,objects or disposable assembly.

# ASort phase6: bounded mixed default order

Own MIT on0b19c9755f12a7aa79b7201ff621b658e0c2a6e1 (phase5 delivered).
Julio Ponce's MIT a04 and Harbour output are specifications only,no copied
implementation or cambio.diff. No workflows,push or publication.

Local literal discovery now admits supported mixed leaves for default
ASort. Shared local literal trees accept empty children and SToD/hb_SToD
with exactly one constant string argument. Private descriptor106 is a
borrowed length/text pair;build calls the existing date parser and installs
a scalar tag11 date. Runtime cells never retain106. Module STATIC admission
is unchanged. Arbitrary computed array leaves remain outside this entry.

Shared ASort validates all cells before moving any. Supported families:
array,text,logical,date,number,NIL,ranked in that order. Int/float form one
numeric family,strings use full byte order,logical/date use scalar order.
Arrays compare equal to arrays and NIL equal to NIL,so the current stable
adjacent sorting preserves their input order. Unsupported payloads still
raise the existing type error. No callbacks or comparison-sequence claim.

Gate56:6 own+a04,28exact executions across4Linux modes,7strict final
balances,21non-Linux profile rejections. Fresh Harbour covers invalid and
empty dates,leap date,trailing input,year zero,subranges,received aliases,
rebuild ownership,stable child order and157exceptions. Dates are printed
as dates;DToS on generic shared cell still requires static date evidence
and is not widened here. Strict balance requires exact stdout,rc0,empty
stderr and measured DELTA0,never a missing marker.

Former phase1 limit-mixed is now executed against fresh Harbour rather
than dropped. Phase1gate81 replaces74. Phase2..5:51,32,37,40. Timestamp1..9,
B1/B2,A1/A2,cycle59,nested51,Rust99 pass. Linux1176exact plus the identical
inherited ctod_order_epoch failure. Negatives622 retain13known mismatches;
PE emission1912PASS22known0FAIL,no PE runtime claim. Censo48/1041 remains
unchanged because this stage closes the separate ASort specification a04.

    python tests/asort-phase6/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort6-check

Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence.
No binaries,objects or disposable assembly. a05..08,c02,e18..20 remain open.

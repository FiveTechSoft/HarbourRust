# ASort phase7: bounded direct scalar callbacks

Own MIT on1a2b4682255e7bf0f481f14b4439975d0674a572 (phase6 delivered).
Julio Ponce's MIT a05 and Harbour output are specifications only,no copied
implementation or cambio.diff. No workflows,push or publication.

Shared ASort admits a direct two-parameter block whose final expression
is a scalar comparison of parameters/literals,or a logical literal.
Optional QOut calls of those atoms before the tail provide exact traces.
Captures,arbitrary calls,indexed row keys,mutation and nonlogical results
remain named rejections. Blocks elsewhere remain outside local A2.

Own helper uses recursive split floor(n/2),sort left then right,query the
block(right,left),and choose right only for true. A right choice rotates
whole tagged cells into position. No temporary heap,no cells or references
removed from the array across callbacks,no callback-sequence shortcut.
This is stable for strict comparisons;non-strict/constant-true comparators
follow their measured merge decisions rather than a promised stability.
The recursion needs O(log n) stack;cell rotations may take O(n^2) moves.
This stage deliberately favors bounded ownership safety over move speed.

Gate50:5own+a05,24exact executions across4Linux modes,6strict final
balances,18profile rejections,2named callback limits. Fresh Harbour traces
for lengths2..9,subranges,negative/zero/past-end starts,zero count,constant
true/false comparators and strings match byte for byte. Repeated numeric
int/float sorts preserve aliases and return identity. DELTA0 requires
exact stdout,rc0 and empty stderr. No missing-marker pass.

Former phase1 limit-block now runs differential instead of being dropped;
phase1gate88 replaces81. ASort2..6:51,32,37,40,56. Timestamp1..9,B1/B2,A1/A2,
cycle59,nested51,Rust99 pass. Linux1176exact plus identical inherited
ctod_order_epoch failure;negatives622 retain13known mismatches unchanged.
PE emission1912PASS22known0FAIL,no PE runtime claim. Censo48/1041 unchanged.
Original a06,a07,a08,c02,e18..20 remain open. In particular QOut traces do
not close a07's helper+module STATIC storage requirements.

    python tests/asort-phase7/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort7-check

Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence.
No binaries,objects or disposable assembly.

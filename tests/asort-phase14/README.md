# ASort phase14: bounded throwing comparison helper

Own MIT on569e92754150bc2f56303c9501fce7d71af1dab4 (phase13 delivered).
Julio Ponce's MIT e20 exception intent and fresh Harbour output are
specifications only,no copied implementation or cambio.diff.
No workflows,push or publication. e20 as a whole is NOT closed.

Direct shared callback may call a structurally checked three-parameter
helper:increment one module STATIC integer by1,compare that slot to the
third parameter,conditionally Break with literal text,and RETURN comparison
of the first two parameters. No other statements/effects or array mutation.
Its arguments follow the existing safe read-only expression restriction.
The checker verifies ordinary arity/types;captures stay borrowed read-only.

The merge helper needs no change:every cell remains in the owning array
before calling the callback. A thrown comparison leaves the current whole
cell permutation intact and ordinary sequence unwind owns the exception.
There is no temporary heap allocation to unwind from the merge itself.

Gate20:2own,10exact executions across5Linux modes(including --no-prune),
2strict final balances,6profile rejections,2named mutation/helper limits.
Fresh Harbour covers151throwing string sorts and137throwing row-key sorts,
recovery,subsequent successful sorting and element/length preservation.
DELTA0 requires exact stdout,rc0,empty stderr and a measured marker.

ASort1..13 pass:88,51,32,37,40,56,57,49,33,27,24,63,29. Timestamp1..9,B1/B2,
A1/A2,cycle59,nested51,Rust99 pass. Linux1176exact plus identical inherited
ctod_order_epoch failure;negatives622 retain13known mismatches unchanged.
PE emission1912PASS22known0FAIL,no PE runtime claim. Censo48/1041 unchanged.
c02,e20 remain open. Original e20 blocks earlier on loop counter k's
noninteger local typing. Its hb_memcheck assertions and type-error path
are not claimed by these smaller differential fixtures.

    python tests/asort-phase14/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort14-check

Reduced bundle/patch,LEEME,attribution,manifest,compilerSHA,raw text evidence.
No binaries,objects or disposable assembly.

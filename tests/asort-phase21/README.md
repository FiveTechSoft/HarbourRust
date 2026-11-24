# ASort phase21: explicit complete supplied-program matrix

Own MIT test-only incremental on902ec1b2555659b6e1723657d7b58a5252c1410c.
Julio Ponce's MIT16programs and Harbour outputs are specifications only,
no implementation or cambio.diff used. No workflows,push or publication.
No compiler/runtime changes. Same final compiler SHA as phase20.

Runs ALL16supplied ASort programs in one gate and refuses silently changed
inventory counts. Fifteen programs are freshly compiled and run against
Harbour with -gtstd. Every byte of stdout must match,rc0,empty stderr.
The original e20 is explicitly the exception: run unchanged against its
internal assertions and pending0,not labeled exact-Harbour. Its separate
adapted semantic comparison remains in phase19,with syntax/error-handler
and hb_memcheck caveats. No original source is edited in this matrix.

Five Linux modes per program: native,external assembler,no VAS arrays,
no escape analysis,no prune. One independent strict final balance per
program,requiring actual marker,stdout match,rc0,empty stderr,DELTA0.
Three profile rejections per program,not non-Linux runtime support.

Gate144:75fresh exact-Harbour executions,5internal-only executions,
16strict final balances,48profile rejections. Source SHA is stored for
every input. Fifteen-of-sixteen differential coverage is now a direct
single-gate result,not inferred by combining per-phase counts.

This does not close all possible ASort forms,all platforms,or e20 raw
original differential. c02 uses bounded static literal-wrapper reduction,
not generic dynamic optional blocks. e20 raw assertions and adapted
semantic comparison remain distinct evidence classes.

    python tests/asort-phase21/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort21-check

Existing phase20 final full regressions are reused with their unchanged
compiler SHA: ASort1..19,timestamp1..9,B1/B2,A1/A2,cycle59,nested51,
Rust104,Linux1176exact+1inherited ctod,neg622/13known,PE1912PASS22known
0FAIL,censo48/1041. Not a claim those were rerun after a test-only edit.

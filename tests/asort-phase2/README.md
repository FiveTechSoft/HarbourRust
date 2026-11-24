# ASort phase 2: dynamic received-cell writes

Own MIT on2ab8a2b737b530b285a256309c2e63a00d3bd6a1 (ASort phase1 delivered).
Julio Ponce's MIT c01/c04 and Harbour outputs are specifications only.
No copied implementation or cambio.diff. No workflows,push or publication.

A constant local literal passed directly to a function selects existing A2
when that function directly stores another parameter into a received cell,
or stores a local initialized by a call that reads a received cell. This
admits c01/c04 without globally changing legacy by-value integer arrays.
The syntactic trigger is conservative,not full type/escape inference.
It does not yet make ASort of a received parameter work (a10 remains open).
A2's existing propagation,cloning,root collection and restrictions do the
execution. No runtime/codegen changes in this phase.

Gate51:four own tests+c01/c04,six sources x4Linux modes=24 exact executions,
six strict final balances,18 non-Linux profile rejections,three A2 limits.
Includes repeated writes,text ownership,157exceptions and read-transform
write-back. Strict balance requires exact stdout,rc0,empty stderr.

    python tests/asort-phase2/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort2-check

Regressions:ASort1=67,timestamp1..9,B1=152,B2=115,A1/A2,cycle59,nested51,
Rust99. Linux1177:1176 exact plus inherited ctod_order_epoch failure,
identical to phase1 and main63. Negatives622 unchanged including13known
mismatches. PE emission only1912PASS,22known,0FAIL. Census48/1041 unchanged.
No Windows/Mac runtime claim. Hashes,blocks,constructors remain A2 limits.
This closes two more supplied programs,not the remaining callbacks/mixed
arrays or full ASort package. Bundle/patch,LEEME,attribution,manifest,
compiler SHA and raw text evidence,no binary/object/disposable assembly.

# ASort phase19: explicit adapted e20 semantic comparison

Own MIT test-only incremental on6d01aa56ccefc65845f64114cebe5a8a3bab4c08.
No compiler/runtime change. Julio Ponce's MIT e20 is specification input,
never implementation or cambio.diff. No workflows,push or publication.

This adds an independent but explicitly ADAPTED Harbour comparison of
Exercise. The input must contain exactly3TRY/CATCH/END sequences. For
Harbour only,those spellings become BEGIN SEQUENCE/RECOVER/END SEQUENCE
and an INIT installs ErrorBlock({|err|Break(err)}). The compiler fixture
keeps original Exercise text and TRY/CATCH,without that INIT. Both get a
new Main calling Exercise21times and printing exercise-count21. Neither
fixture calls hb_memcheck. All Exercise assertions are retained: each
call verifies300recoveries and total5900 or raises an error.

Both generated fixtures,source hashes,raw builds and executions are in
the evidence. Thus5modes compare the same Exercise workload with explicit
error-handler/syntax adaptation. A sixth check independently measures
compiler fixture strict final ownership DELTA0. No assertion that Harbour
has hb_memcheck,that default error handlers match,or that raw-original
e20 is independently differential-closed. Original e20 memory checks
still run unchanged in phase17's separate5mode internal assertion gate.

Also includes a row-writing helper that returns a scalar comparison,
rejected by the callback read-only guard. This avoids confusing a write
with an unsupported returned row. It is a negative scope test,not new
support for direct row-comparison helper parameter inference.

    python tests/asort-phase19/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --spec-root /path/to/julio/programas --output /tmp/asort19-check

Gate7:5adapted exact runs,1strict balance,1named write rejection.
ASort1..18,timestamp1..9,B1/B2,A1/A2,cycle59,nested51,Rust99 pass with
the same compiler as phase18. Linux1176exact+1inherited ctod failure,
neg622/13known,PE1912PASS22known0FAIL,censo48/1041unchanged. This is
additional evidence,not a production capability expansion.

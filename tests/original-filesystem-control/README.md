# Mandatory intact filesystem and cursor originals

Own MIT test-only increment on42127569b202e03a8e2dafba3b25b26659cffdc5.
No compiler,workflow,push,publication or policy change. Upstream originals
are external specifications only. Julio Ponce's MIT ASort examples remain
credited independent specifications;no cambio.diff/implementation used.

Six intact mandatory originals:fileio,fileio2,flink,libname,curdirt,cursor.
30exact executions in five Linux modes plus six strict zero final balances.
Each normal run requires rc0,exact stdout,empty stderr and exact filesystem
effects. Same fresh cwd spelling for oracle and each candidate removes
false CurDir differences. All effects are confined to that test directory,
recreated before every run and removed afterward. File bytes are recorded
in hex,sizes checked,hard-link equivalence groups compared,symlink targets
compared without following them. Oracle fileio content and flink topology
also have explicit expectations. Cursor receives five recorded LF bytes.
No inherited terminal,optional originals or source edits. Missing inputs
fail rc2. Timeout is failure. The include path is the real upstream path.

Balance probe writes an unconditional DELTA=0 marker after persistent,
string-cache and arena cleanup,then continues the real shutdown path.
It requires rc0,exact stdout,exact marker stderr and exact side effects.
The initial development probe exited99 at the marker and skipped the last
console flush,losing fileio's trailing newline despite balance0. That
attempt failed and is retained;the final probe does not weaken stdout
comparison or count a missing marker as success. No production change.

Already admitted programs now have mandatory repeatable evidence,not six
new implementation closures. No performance/non-Linux runtime claim.
Compiler unchanged SHA256
433f92cce0309246a261788ebe442a29781001f1718b6ab912b09cbc44a8120e.
Broad compiler regressions were not rerun for this test-only gate;known
object-lifetime debt in the separate calls gate stays open.

    python tests/original-filesystem-control/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/filesystem-control

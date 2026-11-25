# Proven scalar Dyn hb_DiskSpace path, own MIT

Extends the ordinary Linux typed-leaf path consumer to an ordinary local
already proven scalar by the existing whole-function scalar-store analysis.
It borrows an owned string (tag4), reads counted bytes, and makes no owner
move, clone, escape or free. Other scalar tags stop at a named rc1 limit with
the normal callstack. That is a limit, not Harbour argument-error parity.
Static, shared, module, byref, container and unproven-call locals excluded.
Computed path expressions remain excluded; computed scalar strings may first
be stored into a proven local. Literal selectors0..3 and existing platform,
macro and threading boundaries remain. General RC/object lifetime unchanged.

check.py:45 controlled own triples,9 snapshots x5Linux modes. Includes
omitted argv, scalar string reassignment, empty/whitespace and producer trees.
original.py:45 controlled triples of intact upstream tests/diskspac.prg.
Both inject Harbour statvfs and the native helper statfs result from identical
fields. Snapshot injection is NOT live filesystem parity.
live-original.py:24 actual-syscall stable rows,oracle+5Linux modes x4argv
cases,using the same synthetic argv0 to give identical default DirBase text.
Includes omitted/empty,stable tmpfs and missing-path argv. Not arbitrary
changing root-disk exactness. --spec-root selects the external upstream tree.
limits.py:12named runtime limits(NIL/int/double/logical x3modes),5compile
boundaries(date store,usercall,array,byref,static). balance.prg:1000 borrowed
reads/reassignments,3modes strict final allocation difference0.
The old diskspace Dyn-local negative is explicitly promoted into this suite;
its replacement is an unproven user-function path. Existing10limits retained.

Upstream Harbour external oracle commit694428e1c12f726675b19324d62167fa77d68185.
https://github.com/harbour/core.git . No Harbour implementation copied.

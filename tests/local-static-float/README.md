# Function-local STATIC floating storage

Original MIT. Literal Float/FloatV local STATIC declarations now register F64
storage under the function-qualified persistent label. Existing canonical
read/store routes carry IEEE bits and packed width/decimal metadata, so frames
and recursive calls see the current slot instead of resetting it on entry.
No new ownership or RC route. Ordinary Linux only.

50 new exact stdout/stderr/rc triples,10 sources x5modes: persistence, independent
same-name module/two-function slots, recursion, widths, INIT/Main/EXIT, QUIT,
by-value copy, division across calls, +=/-=/*= and a method-local static.
105 previous float-store/read triples remain exact. The old local-static limit
is now admitted (expected, not a retained rejection).15 own rejected sources
plus Windows and experimental LLVM checks =17 limits. Retag int/string/NIL/
logical gives the existing type-mismatch diagnostic. Inline :=, ++/--, @ and
counters have named guards. Captured read n+1.0 rejects by generic capture guard.
THREADS and Str(Dyn) reject through the existing post-inference float lifecycle
guard, whose message still says module although it checks local slots too.
Macro rejects during binding. Nonliteral division initializer1/3 still rejects
at parse time; no folding extension. Hash/logical local STATIC remain outside.

Strict-zero6 (3 prior and3 with actual local float writes),GTSTD88,Rust118.
618 historical negative sources are a DIFFERENTIAL check, not618 valid
rejections. Linux609reject/9admit,Windows618reject. Both targets have10
expected-substring mismatches (19 distinct sources combined),unchanged counts
from base. Only t1613 diagnostic changes (still rejects, new float wording).
The historical manifest expectation for that fixture is already stale and
not treated as a fresh expected-diagnostic PASS.1041 census retains65 admissions,
1 diagnostic-only change initexit.prg (string/array/float guard wording).
Original initexit still rejected for PUBLIC/macro lifecycle, not closed.
No full Linux manifest, performance, FullLLVM or independent rebuild yet.
Fatal runtime unwind divergence remains OPEN. No failed implementation build
or runtime comparison in this increment. An old regression runner still lists
local-static as a limit; its recorded rc0 is the intended new admission.

Negative audit correction: nine Linux admissions are t436,t793,t795,t813,t897,
t988,t1043,t1068,t1691. All are byte-identical diagnostic/rc outcomes in the
base and new compiler. t1613 rejects both targets but the manifest substring
is stale. Windows t1634..t1642 CurDir rejects but misses its expected substring.
The packaged JSONs of ae466ce3/bbd3f3b2,90e0c3b9 and94146cfb already show
these same counts; no new admission in this increment. This does not prove
any admitted historical negative is Harbour-correct. Prior scoped promotion
records exist for t436(array-shared-a2),t793/t795(dyn-for-counter),t813
(date-iso-mask),t897(fixed-cell-increment),t1043(string-bare-copy). atokens-bb
records the old t988/t1068/t1691 and Windows CurDir mismatches. No new oracle
runs on these9 are claimed by this audit. t1613 remains a known stale fixture.
Windows/LLVM shared diagnostic and module-worded local thread guard remain
explicit messaging debts, not missing rejection guards.

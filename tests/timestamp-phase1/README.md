# Timestamp phase 1

Own MIT implementation, no Harbour code. Julio Ponce contributed the programs
and Harbour 3.2 output files used as specification. t01/t02/t04/t07 preserve
those inputs and exact output bytes. parse.prg extracts the parser loop from
e16 and parse.out is exactly its first 23 output lines (including initial LF,
excluding the next line). Other expectations are ours, not Harbour measurements.

Tag 17 is a non-owning scalar. Tag 16 stays the registry-owned shared-array
reference. The 64-bit payload packs Julian day in high 32 bits and milliseconds
since midnight in low 32 bits. Day 0 means absent date, not an absent timestamp;
time-only values remain nonempty. Existing civil-day conversion helpers are
reused with the Unix/JDN offset 2440588. No decimal timestamp payload is used.

Implemented: hb_SToT, hb_TToS, hb_TToD, hb_DToT; ValType T, HB_ISDATETIME,
HB_ISTIMESTAMP and Empty for syntactically known timestamp producers/local
copies. HB_ISDATE continues to mean D only. hb_DToT removes a timestamp's time;
hb_TToS and hb_TToD accept static dates and runtime Dyn Date or timestamp.
Direct output uses the existing SET DATE/CENTURY renderer and HH:MM:SS.mmm.
The parser follows supplied e16's rules for leading digit runs, partial time,
invalid date preserving time, invalid time becoming midnight, and fractions.

Scope is ordinary Linux without threads/macros. These builtins reject other
profiles explicitly; user overrides are not captured. Existing flat-array
AAdd and function/copy paths preserve tag 17. No claim of general shared
array aliasing, arbitrary methods, DBF fields, JSON or all Dyn consumers.
Predicates accept scalars; aggregate predicates are a named rejection.
Empty on unknown generic Dyn remains rejected; phase 1 does not widen it.

Not implemented: hb_TToC/hb_DToC custom formats, DateTime/Hour/Minute/Sec,
timestamp arithmetic or comparison. Known timestamp arithmetic/comparison
gets a compile diagnostic; unknown Dyn comparison guards tag 17 and uses the
existing runtime type-error route. This deliberately does not claim Harbour
comparison semantics. Mixed string appends after a timestamp in a flat local
array remain outside the existing homogeneous array shape.

Run check.py with --compiler and --output (new directory). Exact checks run
instrumented native ELF, external assembler and --no-vas-arrays. Final balance
guards run after persistent cleanup/cache flush and require exact stdout,
rc 0 and empty stderr. Streams state checks assert both stdout and stderr but
are not passed through the stderr-reserving balance guard. A zero balance is
measured evidence, not a general safety proof. No Windows or Darwin execution.

Generate the own C blob with tests/generate_timestamp_asm.py; its recipe pins
source/assembly hashes, GCC flags and the five allowed existing helper calls.

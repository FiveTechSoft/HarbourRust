# Class declarations and ClassName

Original MIT tests, using a fresh external Harbour gtstd executable as the oracle.

Run `python3 tests/class-declarations/check.py --compiler /absolute/hbc --hbmk2 /absolute/hbmk2 --harbour-core /absolute/core --output /new/directory`.

The external tree adds unchanged `tests/classch.prg`, verified against the pinned inventory SHA256 and never copied into the tests or evidence. Positive programs compare rc, stdout and stderr on ELF internal assembler, ELF external assembler, and PE via Wine. Only PE line endings are normalized. Timeouts fail closed. Named negatives check rejection and no output binary.

Covered: bare VAR/DATA lists, child declarations before their parents, inherited layout/virtual slots, unknown parents, inheritance cycles, duplicate list members, malformed lists, dynamic uppercase ClassName through an inherited method, and user method/DATA priority over the universal message. The stress program checks returned strings and fresh temporary receivers. Candidate-only instrumentation checks zero allocation growth after warming class caches and running Work twice; this is not an oracle memory measurement.

Limits: lists with individual INIT clauses remain unsupported; single VAR INIT uses the existing DATA INIT contract. Methods still need their own class declared first. ClassName on a known object takes no arguments in this increment; Harbour accepts ignored extra arguments, so name-args is a declared limit, not a Harbour-invalid program. Super ClassName, Dyn receivers, module STATIC NIL recovery and threads are not extended here. No native Windows/macOS or sanitizer claim.

# D: scalar Date in AAdd

Own MIT implementation. Julio Ponce contributed t09.prg and its Harbour 3.2
output t09.out as the test specification. No implementation diff was applied
or copied. Other cases are our regression expectations, not independently
measured Harbour oracles.

AAdd admits static Date into a local flat tagged array and stores inline
{11, packed YYYYMMDD}; Date has no owned heap payload. Existing Dyn tag-11
reads can be copied into another flat array. ValType recognizes D without a
DBF dependency. Direct Dyn output uses the existing SET DATE/CENTURY renderer.
No new tag, no timestamp, no shared-array or method-result work is included.

Checks cover the supplied t09 bytes, empty dates, scalar mixtures, Date
variables, copied Dyn cells, surviving source-array shrink, growth/shrink, catch recovery,
SET DATE/CENTURY and stdout/stderr parity with static Date. Each console
case also runs with a strict post-cleanup alloc/free guard. The harness tests
both default allocator selection and --no-vas-arrays, plus external assembler.
Empty on a Dyn date cell stays a named rejection. Non-Linux checks are assembly emission only, not runtime claims.

The existing restrictions of flat arrays and scalar Dyn consumers remain.
This does not add date arithmetic, ordering, assignment, Empty or date-part
builtins over arbitrary Dyn values. Unsupported operations remain outside
this increment. Delta zero is measured evidence, not a general safety proof.

Run: python3 tests/date-aadd/check.py --compiler /path/to/hbc --output /new/dir

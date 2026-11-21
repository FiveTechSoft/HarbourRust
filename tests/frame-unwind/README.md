# Recoverable frame-owner cleanup

Own MIT repair, no new accepted syntax. Ordinary Linux/Windows programs with
explicit TRY handlers, excluding macro/MEMVAR, threads and Mach-O. Frame-local
linked records are separate from the256language TRY pads. A handler saves
the current record frontier. Propagation releases only intervening frames,
using their existing shared epilogue, then restores the same handler context.
Normal return unlinks the record before existing owner cleanup. Bin/Cmp,
call argument emission and trace functions are unchanged.

check.py:24own sources,192executions across base/candidate,Linux native/PE64
under Wine,and internal/external assembler. Counted catches,exact zero pending
on candidate,positive baseline pending only where independently confirmed.
3warmup then113calls,or5calls at270recursive depth. Explicit Break,operators,
computed/literal/NIL/logical inputs,two owners,array bounds,local catch,
rethrow,FINALLY,normal return. Memory is allocation balance,not bytes or
Harbour-equivalent memory accounting. Raw build/run rc/stdout/stderr retained.

mutants.py:2own functional reversion variants. Both must compile compiler
and program0,run0,and produce37catches/74pending vsfreshcontrol37/0. A failed
build,signal or timeout is not mutation detection. guard_selftest.py tests
simulation/proxy failures separately.

V1design consuming a TRY pad per owned frame was discarded before commit:
270recursion exposed a new TRYoverflow although the1266manifest passed.
The accepted design must pass that same depth probe. Legacy limitations in
macro/threads,temporaries not owned by frame slots,and nonlocal error cleanup
outside this stated profile remain;this is not general exception-safety.

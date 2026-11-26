# EXIT hooks on normal Linux return

Original MIT implementation. Measured Harbour core 694428e1: INIT runs in
reverse source order, EXIT in source order after Main and before persistent
storage cleanup. Integer, string and constant shared arrays reuse their
existing storage. EXIT FUNCTION may RETURN NIL. Hook arguments, value returns,
NIL/missing STATIC initializers, threads/macros, Windows and LLVM are rejected.
QUIT and BREAK/TRY are rejected in any program containing EXIT hooks. The
exceptional termination route is not integrated. Other fatal runtime errors
retain the existing registered divergence: process abort, no EXIT callback.
This is normal-return support, not a general unwind or lifetime implementation.

Original t1609 simple EXIT source is preserved as former-exit-limit.prg and
measured against Harbour. The negative now uses a value-returning EXIT hook;
its diagnostic changes on both targets. 35 exact triples cover seven sources
across five modes, with three strict-zero sources,12 named compile limits,
Rust118 and GTSTD88 classified checks. Census1041/65 is unchanged in admission;
ct.prg has one later rejection diagnostic. The618-negative gate has only the
expected edited t1609 diagnostic change. Census ct.prg remains rejected with
a later diagnostic. Original tests/initexit.prg still needs module floats and
PUBLIC support; not closed. No Windows execution, performance, multi-unit
linking or independent compiler rebuild is claimed.

C2 fatal-runtime follow-up: source-level division by zero with EXIT is a
measured divergence. Harbour headless substitutes0, returns0 and executes EXIT.
This compiler returns1 without EXIT, but now reports on stderr:
EXIT hooks skipped: fatal runtime termination (normal-return-only)
The notice is attached to explicit failing Linux exit syscalls after all
runtime producers, so it also covers bounds/type/other named abort routes.
It preserves registers and flags. It does not turn process abort into unwind.
Normal successful exits do not print it, and programs without EXIT are unchanged.
An out-of-range-index oracle probe opens its error dialog and times out;
that probe is not evidence of oracle completion or hook execution.

The LLVM limit uses --experimental-llvm and has a separate LLVM diagnostic;
Windows keeps the platform diagnostic. EXIT between ordinary functions and
INIT/EXIT interleaving have oracle-exact fixtures. ct.prg remains rc1: the
old parser stopped at EXIT on line75; the new parser gets to unresolved
ctcinit on line53, an external C extension not linked by this standalone test.

The fatal divergence remains OPEN: fatal abort does not execute EXIT,
persistent_cleanup or string-cache flushing. The notice is mitigation only.
GTSTD pending output is closed by the pre-existing terminal boundary before
its fatal message; a merged-stream empty-QOut fixture verifies ordering.
Normal-return persistent cleanup, string-cache flush and GTSTD close still
precede final process exit.

C2 notice follow-up: a completed-hooks flag suppresses the notice after all
hooks return, even at a synthetic nonzero final status. ErrorLevel(7) itself
is still unsupported (explicit unknown-function compile error); Harbour runs
EXIT then exits7. The synthetic final-status fixture is a helper boundary
check, not an ErrorLevel implementation claim. Each inserted helper call
reserves128 bytes with LEA, preserving the caller's entire x86-64 red zone.
Canaries at -8/-128, registers and flags are checked on fatal, nonexit and
hooks-completed routes. No stack alignment assumption or user hook is needed.

QUIT follow-up: see ../exit-quit/README.md. Ordinary Linux EXIT+QUIT without
INIT now has a measured route; earlier blanket QUIT exclusions describe the
previous increment. Fatal exceptions and BREAK/TRY remain outside unwind.

Startup follow-up: ../init-exit-quit/README.md documents the measured
INIT+QUIT+EXIT route. Older exclusions above describe the earlier increment.

ErrorLevel follow-up: ../errorlevel/README.md implements the measured ordinary
Linux i64 route; older unsupported statements above describe prior versions.

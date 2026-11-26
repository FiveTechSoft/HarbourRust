# QUIT during INIT when EXIT hooks exist

Original MIT. Harbour core694428e1 oracle: QUIT in INIT or a deep callee
skips remaining reverse-order INIT hooks and Main, then executes EXIT hooks
in source order. The saved entry stack/phase is now initialized before INIT
calls, after persistent string/array initialization. Existing Main/EXIT QUIT
routing is unchanged. Static string/int/array strict-zero probes include
startup interruption and final cleanup.

INIT+QUIT without EXIT still has the previous explicit rejection. Threads,
macros, BREAK/TRY and fatal unwind remain outside this increment. Fatal
runtime divergence is OPEN and emits the existing notice, not EXIT callbacks.
This does not close original initexit.prg (module float and PUBLIC remain).

Follow-up ../init-quit-noexit/README.md removes the prior no-EXIT exclusion
after separate oracle measurement.

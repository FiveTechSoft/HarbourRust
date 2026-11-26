# QUIT with ordinary Linux EXIT hooks

Original MIT. Black-box Harbour core 694428e1 measurements: QUIT in Main
starts EXIT hooks in source order; QUIT inside an EXIT hook, including a
callee several levels deep, skips remaining hooks. A saved Main stack pointer
plus teardown-phase flag selects direct labels. Persistent cleanup, string
cache flush and GTSTD close still run once. No indirect jump relocations.

Only ordinary Linux without INIT hooks, threads/macros or BREAK/TRY. The
combination INIT+EXIT+QUIT is explicitly rejected: startup interruption is
not measured or implemented. Fatal-runtime exceptional teardown remains OPEN
as documented in exit-hooks; this does not implement fatal unwind, nor
ErrorLevel, module floats, PUBLIC, object RC or cross-unit linking.

First candidate used indirect RIP-relative jump: external path exact but
internal assembler failed12/20 runtime comparisons. The replacement uses
direct branches and passes20/20 comparisons. Earlier failed attempt retained.

Startup follow-up: ../init-exit-quit/README.md documents the measured
INIT+QUIT+EXIT route. Older exclusions above describe the earlier increment.

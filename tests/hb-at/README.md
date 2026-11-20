# hb_At typed byte ranges

Own MIT implementation, external Harbour executable oracle only.

Ordinary Linux, two typed strings and optional I64 bounds or literal NIL.
Search is case-sensitive on bytes. Start is inclusive, 1-based; start0 uses1,
negative start finds0. End is inclusive, clipped to length using unsigned
comparison (negative end therefore means the full text); end0 finds0.
An empty search finds0. Bounds are evaluated left to right after both string
snapshots, so mutation of their owners cannot invalidate earlier arguments.
A local sequence landing pad drops initialized snapshots if any argument
throws, then continues the original unwind. Normal cleanup drops both copies.
At and hbc_at runtime implementation are unchanged.

Dyn/F64/bool/string bounds are explicit limits, not silent coercions. The
oracle truncates float bounds and uses default bounds for nonnumeric values;
this increment does not implement those shapes. PRIVATE/PUBLIC/macro/thread
contexts and other targets are explicit limits. Dyn strings remain outside.

22 own sources /44exact int/ext oracle pairs; effects in text/start/end,
integer extremes, byteNUL/255, boundary clipping, nesting and parameters.
17compile-time limits, including14fresh executable oracle controls.
15instrumented lifetime modes with throwing search/text/start/end and normal
calls,100warmup+10000measured iterations,zero delta. CATCH variable is declared
before TRY: auto-declared final CATCH string ownership has a separate prior
base defect. Do not claim this gate fixes it. Raw failed prototypes retained.
3Rust-valid mutants must build/run0 and differ from oracle-equal controls;
4fake rustc proxies prove failure-closed gates,not product mutants.
at_identity.py preserves old At fixture assembly exactly across4targets.

Census scratch1041: no acceptance changes.2first-error modules advance:
occurs.prg to increment/decrement on Dyn;xhbmisc.prg to typed-string limit.
These are not2unlocked standalone programs. No external implementation copied.

# INKEY on Windows PE (Wine)

Scope: `INKEY()` / `INKEY(<numeric literal 0.01..86400>)` reading stdin in a Windows PE (internal assembler/PE writer and
`--external-as` mingw path), compared with the external Harbour 3.2.1dev r2610242111 (mingw, `-gtstd`) oracle under Wine.
Not Harbour 4. Wine only, not native Windows; no real console is measured.

Measured oracle behaviour (check.py, persistent wineserver; timing is the delta over a no-INKEY baseline of the same stdin kind):
- data available: first byte at once (Z=90, A=65 then B=66, CR=13, FF=255), no wait for the timeout;
- EOF (/dev/null, empty file, closed pipe): 0 after waiting the full timeout (INKEY(1) ~1 s, INKEY(0.2) ~0.2 s); INKEY() waits 0;
- the ~5 s seen on file stdin in raw probes is Wine cold start (wineserver), also present in a program without INKEY.

Implementation (`hbc_inkey` for Windows): GetStdHandle(-10), GetFileType, GetTickCount64 deadline.
Pipe: PeekNamedPipe + Sleep(1) slices; if Peek returns ERROR_NOT_SUPPORTED (Wine answers this for anonymous pipes) the
helper does a blocking 1-byte ReadFile like the oracle does and, as measured, then waits the FULL timeout after that read hits EOF (not the remainder); another Peek error is a closed pipe (EOF).
Other handles: 1-byte ReadFile; 0 bytes or failure is EOF. EOF with a timeout sleeps the REMAINING time, result 0.
New imports (whitelisted): GetFileType, PeekNamedPipe, GetTickCount64.

Limits (honest):
- Under Wine a live, quiet pipe (stdin open, no data, never closed) is not pollable: the oracle blocks there (>30 s, killed),
  and so does this implementation. Those cases are not in the gate. On real Windows the timeout is EXPECTED to be honoured through PeekNamedPipe, but that is NOT tested here
  (Peek can also block on synchronous handles with several threads).
- Real console stdin (GetFileType CHAR on a console) is not measured: ReadFile is blocking there and there is NO timeout guarantee; WaitForSingleObject is always signalled under Wine, so it is not used.
- Timing tolerance: delta must reach the timeout minus 0.05 s and be within 0.8 s of the oracle (Sleep(1) granularity).
- Mask argument, 0, negative, NIL and runtime timeouts, LLVM and Darwin stay rejected/unmeasured.

Values and timing are separate: rc, stdout and an empty stderr must equal the oracle's and are never retried. Only the timing
part may be retried once in a fresh directory (a concurrent build slowed a delta from 1.0 s to 2.8 s in one run); the retry is explicit
in results.json (`timing_retry`, `attempts`, `first_attempt`).
The 0.01 s case only proves that a tiny timeout returns 0 on EOF without a long wait (margin 0.05 s); it does not prove 10 ms accuracy.

ABI proof (`abi-*` cases): every API call inside hbc_inkey goes through a stub that, after the real call, overwrites the whole
outgoing area (32-byte shadow space + stack args 5/6, rsp+0..47) with junk. The pre-fix layout (locals at rbp-56/-48/-40 inside that
area) returns 0 instead of the byte; the fixed layout (frame 112, locals rbp-8..-56 above the outgoing area) passes.

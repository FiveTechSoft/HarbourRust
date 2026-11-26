# QUIT during INIT without EXIT hooks

Original MIT. Oracle Harbour694428e1: QUIT in INIT directly or through a
callee skips remaining INIT hooks and Main, then exits0. Reuse the measured
startup teardown route even with an empty EXIT list. One route-activation
condition changes; teardown emission already handles the empty list.
Persistent cleanup and string-cache/GTSTD close still run. Three strict-zero
fixtures cover strings, integers and shared arrays. Threads/macros and fatal
exceptional unwind remain outside this route. Fatal divergence is OPEN.

C2 guard follow-up: all INIT+QUIT routes without EXIT explicitly reject
threads, macros and Str(Dyn) contexts after inference. Previous compiler
e933a9b7 admitted the macro and Str(Dyn) probes (rc0); it rejected threads
later in emission. The new common guard rejects all three before emission.
Two additional oracle fixtures cover QUIT in Main and a callee from Main,
not only during INIT. Ten comparisons across five modes are exact.

Evidence limitation from prior package: two failed apply-check preparation
attempts (ENOSPC and path absent in base) had logs overwritten. Those logs
are absent and cannot be reconstructed as original evidence. No such failure
is counted as PASS. This delta attempts a full detached-base checkout check.

# GetEnv, ordinary Linux

Own MIT implementation. External Harbour executable is the oracle only.

Exactly one typed string key. Returns an independent owned string copy.
Lookup is case-sensitive, a NUL in the key ends the effective C key, '=' or
an empty/missing key returns empty. UTF8 and other bytes are preserved.
The helper scans the process environment vector saved at entry, before INIT.
It has no fixed slurp buffer and no 64KiB environment truncation. Tests use
only named HR_GETENV_* fixture keys, never inherited private environment data.

Ordinary Linux only. Rejects threads, macro/PRIVATE/PUBLIC profiles and any
EXTERNAL C declarations. This closed subset has no environment mutation API;
C extensions could replace environ and invalidate the saved-vector contract.
Noargs, nonstring, Dyn and multiple arguments remain named build limits,
although the measured oracle returns empty for those broader shapes.
No new ABI, Bin/Cmp/Ret/trace or workflow change. Entry capture and helper
emit only when GetEnv is referenced. Calls without it keep their old emission.

19own sources38exact int/ext oracle pairs include INIT, empty/missing keys,
embedded NUL, UTF8, 70KiB value, ownership/cache reuse and key effects/throw.
6memory modes100warmup+10000lookups, exact totals and zero allocation delta.
14named build limits, no rejected binary executed.
3Rust-valid functional mutants must build compiler/program0, run0, and have
stdout different from fresh exact controls.4proxy failure tests are separate.

Original runshell advances to unknown hb_processrun at compile time; it is
never executed. cdpdet remains explicitly rejected because it declares C
extensions. No new standalone acceptance is claimed.

A prior unrelated byref call nested in TRY may lack its specialized symbol;
Upper(Key(@n)) reproduces that on baseline without GetEnv. Not changed here.

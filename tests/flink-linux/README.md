# Linux filesystem links and FError

Original MIT implementation and test sources. Harbour is an external oracle
only. New primitives use Linux syscalls, no Harbour runtime or source code.

Ordinary Linux x86-64 single-thread programs only. Other backends and any
program using threads are rejected for these new builtins.
- hb_FLink/hb_FLinkSym take two typed strings or no args. Return0 or-1,
  update FError. No args returns-1/error2. One/extra/nonstring args rejected.
- hb_FLinkRead takes one typed string or no args, owned counted string.
  Measured truncation264 bytes, even when link target is longer. No args
  returns empty/error2. Does not follow dangling link targets.
- hb_MemoWrit takes two typed strings, writes exact counted bytes, no CtrlZ.
  Returns logical, preserves FError. Optional third argument not admitted.
- hb_DirCreate takes one typed string or none. Returns mapped error code,
  or-1 without args. Preserves FError. Mode0777 subject to process umask.
- FError getter has no args. Its flag is separate from internal syscall errno.
  Prior FCreate/FOpen/FRead/FReadStr/FWrite/FClose now update the flag too.
  Empty FWrite returns0/error13 without syscall; oversize FRead returns0/error0;
  zero-count FRead makes a real read0 so invalid handle reports6.
- Paths truncate at NUL; payloads are counted bytes. Paths are owned snapshot
  copies made left-to-right, before later argument evaluation can consume
  their source. Nested call consumption still applies.
- errno mapping measured using own external oracle adapter over public API;
  identity except sixteen measured exceptions, not Windows OS semantics.
  No real-Windows behavior, cross-filesystem copy fallback or overwrite.

check.py compares original flink.prg without modifications, real filesystem
nodes (including hard-link counts, symlink targets, bytes and modes), error
paths/permissions/ELOOP/long names/NUL,264-byte boundary, old I/O FError,
argument lifetime/consumption and memory after1000 iterations. Linux internal
and external assembler. Unsupported types/arity/platforms fail closed.
The source tree under --harbour-core stays external and hash checked.

## v2: recoverable errors during later argument evaluation

A local sequence pad protects owned path/payload snapshots only when a user
TRY is already active. On Break/type error in a later argument it frees every
initialized snapshot and rethrows the unchanged pending exception. Early copies
remain necessary when later arguments consume the earlier owner. Gate adds
1000 iterations of second-argument Break and Dyn NIL division in FLink,
FLinkSym and MemoWrit, memory delta0 after warmup (internal/external), and
checks a preserved Break value. v1 leaked six allocations per iteration.

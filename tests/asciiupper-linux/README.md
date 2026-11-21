# hb_ASCIIUpper, ordinary Linux

Own MIT counted-byte ASCII uppercase copy. Harbour executable is external
oracle only. Exactly one typed string argument. Only byte values97..122
change,by subtracting32. Bytes128..255 and UTF8 byte sequences stay unchanged.
NUL does not end processing. Every result is an independent owned string,
including empty or already-uppercase input. No locale/codepage lookup.

Ordinary Linux only,no threads or macro/PRIVATE/PUBLIC contexts. Dyn,
noargs/nonstring and extra arguments remain named build limits. The oracle
ignores extra arguments,while this increment rejects them. Nonstring and
missing argument errors are caught in the preimplementation oracle probes,
not implemented runtime. No filesystem effects.

17own sources34exact int/ext pairs,including all256bytes,NUL,UTF8,70KiB,
retention/cache reuse,parameter,effect once and throw.6memory modes with
100warmup+10000calls,int/ext,total exact anddelta0.13named build limits,
no rejected binary run.3Rust-valid functional mutants build compiler/program0,
run0 and differ in stdout from fresh exact oracle controls.4proxies separate.
Original getsyshb is compile-only,never executed;next rejection reported
separately. No external body copied into product/tests,not standalone support.

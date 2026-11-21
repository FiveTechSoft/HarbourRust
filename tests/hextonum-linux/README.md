# hb_HexToNum, ordinary Linux

Own MIT counted-byte hexadecimal parser. Harbour executable is external
oracle only. Exactly one typed string. Leading ASCII spaces only are skipped.
Digits0..9,a..f,A..F accumulate modulo2^64 and the result is signed i64.
NUL ends the effective string. Any other byte before NUL resets the entire
result to0,including trailing spaces,tabs,signs and0x/$prefixes. Empty or
spaces-only returns0. Long inputs wrap rather than saturate or trap.

Ordinary Linux only,no threads or macro/PRIVATE/PUBLIC contexts. Dyn,
noargs/nonstring and extra arguments remain named build limits. The oracle
ignores extra arguments,while this increment rejects them. Missing/nonstring
arguments raise oracle errors,not implemented runtime. Input is borrowed;
owned temporaries are released after parsing. No result string allocation.

40own sources80exact int/ext pairs:valid/invalid syntax,leading whitespace,
NUL,highbytes,64bit boundaries,wrap,70KiB,param,effect once,throw,retained input.
6memory modes100warmup+10000calls,int/ext,total exact anddelta0.13named build
limits,no rejected binary run.3Rust-valid functional mutants build compiler/
program0,run0 and differ in stdout from fresh exact oracle controls.4proxies
separate. Original hex2dec alone advances to no main;one own include-driver
executes unchanged pinned library,2exact int/ext oracle pairs. No external
body copied into product/tests,no standalone acceptance claim.

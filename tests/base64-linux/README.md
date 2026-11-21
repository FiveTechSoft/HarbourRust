# hb_base64Encode, ordinary Linux

Own MIT counted-byte standard base64 encoder. Harbour executable is external
oracle only. Exactly one typed string argument. Standard alphabet A-Z,a-z,
0-9,+,/ and '=' padding,no line wrapping. Empty returns owned empty string.
NUL,highbytes and UTF8 are raw input bytes. Input length produces
4*ceil(length/3) bytes with overflow checked before allocation. Independent
owned output;borrowed input,temporary input cleanup follows builtin rules.

Ordinary Linux only,no threads or macro/PRIVATE/PUBLIC contexts. Dyn,
noargs/nonstring and extra arguments remain named build limits. Oracle
returns empty for noargs/nonstring. Optional numeric width can add CRLF;
this increment does NOT admit width or any second argument. No decoder.
No filesystem effects.

39own sources78exact int/ext pairs,including all256bytes,NUL,UTF8,70KiB,
padding and length boundaries,retention/cache reuse,param,effect once,throw.
6memory modes100warmup+10000calls,int/ext,total exact anddelta0.
13named build limits,no rejected binary run.3Rust-valid functional mutants
build compiler/program0,run0 and differ in stdout from fresh exact oracle
controls.4proxies separate. Original base64.prg compile-only,never executed;
next rejection enumkey on Dyn,not decoder support or standalone acceptance.
No external body copied into product/tests.

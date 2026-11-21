# hb_StrToHex, ordinary Linux

Own MIT counted-byte uppercase hexadecimal encoder. Harbour executable is
external oracle only. Exactly one typed string argument. Two uppercase ASCII
hex digits per input byte, no separator. Empty returns an owned empty string.
All256 byte values, embedded NUL, UTF8 bytes and70KiB inputs are measured.
Returns an independent owned string. Temporary input cleanup follows normal
borrowed-builtin rules, including nested consuming calls.

Ordinary Linux only, no threads or macro/PRIVATE/PUBLIC contexts. Dyn,
noargs/nonstring and multiarg remain named build limits. The oracle accepts
a string separator, including multibyte/NUL separators, but this increment
does not admit that optional argument. Nonstring arguments raise an oracle
error caught by the preimplementation probes. No filesystem effects.

17own sources34exact int/ext pairs;6memory modes100warmup+10000calls,
int/ext,total exact anddelta0;13named build limits,no rejected binary run.
3Rust-valid functional mutants build compiler/program0,run0 and differ in
stdout from fresh exact oracle controls.4proxies check the gate separately.
Original byt2hex is checked unchanged by SHA. Alone it advances to no main;
one own include driver runs exact in int/ext against Harbour. The original
body is not copied into product/tests. No standalone acceptance claim.

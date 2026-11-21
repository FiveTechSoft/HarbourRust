# hb_DirSepAdd, ordinary Linux

Own MIT counted-byte implementation. Harbour executable is external oracle.
Exactly one typed string. Empty stays empty. A nonempty string receives '/'
only when its final byte is not '/'. No normalization, no backslash handling,
no embedded-NUL truncation. Returns an independent owned string in all cases.
Temporary inputs are released after the result is safe; variable inputs borrow.

Ordinary Linux only, no threads or macro/PRIVATE/PUBLIC contexts. Dyn,
noargs/nonstring/multiarg remain named build limits. The measured oracle
returns empty for noargs/nonstring and ignores the extra argument, but those
broader contracts are not admitted here. No filesystem effects are needed.

16own sources32exact int/ext pairs, including70KiB,NUL,UTF8,ownership andthrow.
6memory modes100warmup+10000calls,int/ext,total exact anddelta0.
13named build limits,no rejected binary executed.
3functional Rust-valid mutants build compiler/program0,run0 and differ in
stdout from exact oracle controls.4proxies check the positive gate separately.
Original TempFile source only compile-checked, never run; next unknown is
SetFCreate. No standalone acceptance claim.

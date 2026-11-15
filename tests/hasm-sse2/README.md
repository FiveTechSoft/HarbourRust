# Minimal byte-SIMD and adjacent BSF encoder gate

Forms used by the upcoming bounded ASCII-byte helpers only:
- movd GPR32 -> XMM
- movdqu XMM/m128 -> XMM, XMM -> m128
- movdqa XMM/m128 -> XMM (no aligned stores)
- pcmpeqb, pcmpgtb, pand, pxor, punpcklbw, punpcklwd: XMM/m128 -> XMM
- pshufd imm8(0..255), XMM/m128 -> XMM
- pmovmskb XMM -> GPR32
- bsf GPR32/m32 -> GPR32

check.py compares527 instructions against GNU as for all three emitted
containers (ELF, PE, Mach-O). It covers low/high XMM/GPR, base/index extensions,
SIB, disp8/disp32, RIP-relative with/without trailing immediate, and shuffle
immediates0/27/255. Ten unsupported forms reject without panic/output artifact.
The PE-only trailing ExitProcess import is excluded from the common byte
prefix; no new instruction is executed. Mach-O is emission/byte verification,
not a native Mac run. This is an instruction-encoding gate, not a semantic
performance or no-overread test for the future At/Upper/Lower helpers.

Build driver from repository root:
rustc --edition=2021 -O tests/hasm-sse2/driver.rs -o /tmp/sse2-driver
python3 tests/hasm-sse2/check.py --driver /tmp/sse2-driver --output /new/gate

Limits: only listed forms. No MMX/AVX, general vector instruction family,
GPR64 BSF, movd reverse direction or immediate truncation. CPU execution feature
requirements and helper bounds/ABI remain the future helper units' gates.
No At/case emitter or runtime change is included here.

# JSON B1: owned string layout and decoding escapes

Base: 40846e1b9ac5c359e30bc4e9205558af64177fdf. This is the first review chunk of package B, not a complete repair of JSON. Do not merge this chunk alone as completion of B.

Changes:
- Encode output buffers keep capacity at data[-16] and current length at data[-8]. Length is updated on every append, including after growth.
- Decode strings use the same owned buffer, including empty strings, all escapes and every failure cleanup path. Header initialization, growth and freeing no longer disagree about the allocation base or size.
- Unicode consumes exactly four hex digits, combines surrogate pairs, rejects lone surrogates and rejects raw control bytes. UTF-8 remains the documented runtime output policy. These are safety/JSON-format regression tests, not new Harbour oracle observations.
- The ELF GCC regeneration route normalizes its read-only section names to the internal assembler's supported .rodata spelling. Generated assembly and recipe are included. Whitelist unchanged.
- The encode date fixture now uses SToD("20261122"), retaining the existing pinned date bytes instead of depending on the current clock.

Validation:
- tests/json-safety/check.py: four Linux executable string roundtrips (internal/external assembler, each plain/instrumented), exact stdout, exit 0 and empty stderr.
- Standalone C harness: ASan/UBSan plus an exact (base, allocation bytes) registry. Covers short/empty/long strings, 1000 escaped newlines, 1000 Unicode escapes, surrogate pairs, following characters, bad escapes, lone surrogates, raw controls, unterminated strings and encode length/capacity. No live allocation after each case.
- Existing encode fixture: 14 rows exact, instrumented Linux, exit 0.
- PE manifest gate: 1884 PASS, 22 KNOWN-MISMATCH, 0 FAIL. FILE gate: 22 checks. Neither establishes JSON runtime coverage on Windows.

Still pending, intentionally outside this chunk:
- Decoder arrays: capacity/count and copy offsets, error unwind and nested tag-8 release.
- Decoder numbers: exponent semantics, grammar validation and bounded arithmetic.
- Explicit encode rejection/implementation for typed DArr3/DArr4.
- Root-manifest JSON registrations and final README pin counts after full fixes.
- Total-consumption compatibility is unchanged pending oracle evidence.

The broad jsondecode_bb program still fails the instrumented allocation registry on array cleanup. Its output before cleanup agrees, but that is NOT a passing test. jsondecode_escapes now reports four UTF-8 bytes for its escaped e-acute case instead of the former three-byte incorrect result, so that old oracle-derived console-codepage pin is NOT claimed exact. The UTF-8 divergence needs explicit treatment in the later test registration. No Harbour source was used, no new compatibility claim is made, and no remote branch/CI/main mutation is included in this chunk's local tests.

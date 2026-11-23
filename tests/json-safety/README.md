# Historical B1: owned string layout and decoding escapes

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

Historical B1 pending list (superseded by B2 below):
- Decoder arrays: capacity/count and copy offsets, error unwind and nested tag-8 release.
- Decoder numbers: exponent semantics, grammar validation and bounded arithmetic.
- Explicit encode rejection/implementation for typed DArr3/DArr4.
- Root-manifest JSON registrations and final README pin counts after full fixes.
- Total-consumption compatibility is unchanged pending oracle evidence.

Historical B1 result: the broad jsondecode_bb program failed the instrumented allocation registry on array cleanup. Its output before cleanup agrees, but that is NOT a passing test. jsondecode_escapes now reports four UTF-8 bytes for its escaped e-acute case instead of the former three-byte incorrect result, so that old oracle-derived console-codepage pin is NOT claimed exact. The UTF-8 divergence needs explicit treatment in the later test registration. No Harbour source was used, no new compatibility claim is made, and no remote branch/CI/main mutation is included in this chunk's local tests.

## B2 continuation

B2 is based on published B1 9d5e8bcf. Decoder arrays initialize the capacity header, copy all tag/payload cells without copying the header as data, compact to the exact live count before returning, and recursively release partial trees on errors. Unsupported-object errors are delayed until cleanup. hbc_dfree now descends into owned tag-8 children on Linux and Windows. Decoder depth is bounded at 128 arrays.

The number parser requires digits after sign/point/exponent, rejects integer overflow and nonfinite double output, applies exponents to the whole value, and bounds exponent magnitude to 308 with at most nine scale iterations. Fraction precision metadata is limited to 255 digits. JSON leading-zero integer spellings are rejected. These are explicit JSON grammar/safety policies, not newly measured Harbour equivalence. Exponents outside +/-308 and integers outside i64 return NIL, even where another implementation might accept a rounded/underflowed value. The current first-value/trailing-input behavior is unchanged pending oracle evidence.

Encode DArr3/DArr4 now fail by name rather than falling through to null. Buffer size sums and doubling have explicit overflow guards. Raw bytes >=0x80 are still preserved without UTF-8 validation. A resource failure remains the existing runtime type-error path, not a recoverable allocation result.

Validation for B2: ASan/UBSan plus exact allocation registry covers arrays of nine elements, nested strings/arrays, malformed partial trees, deferred object errors with zero live blocks, malformed numbers and extreme exponents, i64 minimum and short/long strings. Generated runtime programs execute nested cleanup under --instrument. The 14-row encode and 14-row decode programs are byte-exact on Linux, plain/instrumented and external-as instrumented. The old three-row Unicode console pin remains unchanged and explicitly divergent in row two; its UTF-8 regression copy is separately named in the root manifest.

Root manifest adds five positive and two negative rows. PE gate: 1891 PASS / 22 KNOWN-MISMATCH / 0 FAIL, emission only. Mac inventory: 1289 executable manifest rows plus 57 auxiliary rows = 1346; 16 runner tests pass with two platform-dependent skips. Rust units: 91/91. FILE: 22 checks. Full Windows/Mac JSON execution and full unrelated runtime batteries have not been performed locally. Deep-clone operations or arbitrary mutation of nested Dyn arrays are not newly certified by this change. No workflow changes or Harbour source use.

## B2 v2 ownership correction

The first B2 draft was rejected: recursive freeing combined with the old shallow tag-8 clone in Break(Dyn) could double-free or use freed children. Both Linux and Windows hbc_darrclone helpers now recursively clone owned tag-8 children. The new break_nested regression throws the same nested decoded local five times, reads both caught and original values, and destroys both owners. The rejected compiler crashes uninstrumented and fails its allocation registry instrumented; this version passes both and external assembly. Root inventory is now 1290 + 57 = 1347; PE 1892/22/0. This supersedes the counts in the B2 draft paragraph.

Exponent literals currently retain dec metadata zero. Fractional roundtrip formatting after exponent parsing is NOT certified, even where the numeric value test passes. B1 comments above describe history, not remaining defects after B2. Windows/Mac runtime remain unexecuted locally.

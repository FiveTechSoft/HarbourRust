# Shared string fill performance gate

This is an internal x64 fill change, not a new Harbour builtin or a change to numeric admission. Counts below 2048 bytes keep the existing 64/8/1-byte store loops. Counts at least 2048 use `rep stosb`. The internal assembler adds that instruction's `F3 AA` encoding and exact mnemonic recognition. Direction flag must be clear, as already required by the x64 ABI and existing REP MOVSB helpers.

Consumers are Space (currently I64), PadR's padding region, and Replicate's one-byte source fast path below 8192 result bytes. Replicate at/above 8192 remains the existing copy-doubling control. A later Space F64 change will inherit this fill; it is not included here.

## Reproduce

Build the compiler from the repository root:

```
rustc --edition=2021 -O -C strip=symbols src/hbc.rs -o /tmp/hbc-fill
```

Build `BASE` separately with the same flags. Set HB to the pinned real Harbour `hbmk2`, not the candidate:

```
python3 tests/string-fill-erms/benchmark.py --compiler /tmp/hbc-fill --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/fill-space --sizes 65536,65537,1048576
python3 tests/string-fill-erms/benchmark.py --compiler /tmp/hbc-fill --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/fill-padr --function PadR --sizes 8,256,4096,65536,65537,1048576
python3 tests/string-fill-erms/benchmark.py --compiler /tmp/hbc-fill --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/fill-replicate --function Replicate --sizes 8,256,4096,65536,65537,1048576
RUSTC=rustc python3 tests/string-fill-erms/abi.py --compiler /tmp/hbc-fill --output /tmp/fill-abi
```

For all Space sizes, omit `--sizes`. To bound a single invocation's elapsed time, split the sizes into groups; outputs must use new directories. The default is five samples plus an untimed exact-output warmup for every implementation. Measurement order rotates among real Harbour, candidate, BASE and malloc/memset C. Raw seconds, iterations, stdout bytes and medians are saved. C is a transform reference without Harbour's VM, registry or cache, not an equivalent runtime. No CPU pinning or machine-wide noise isolation is claimed.

Optional PE/Wine canaries add:

```
--wine /path/to/wine --wine-prefix /path/to/prefix --mingw /path/to/mingw/bin --mlib /path/to/mingw/lib
```

`abi.py` tests 384 cases across lengths 0..1 MiB, four destination offsets and four byte values. It checks every output byte, both adjacent guard bytes, final destination/count, r10, RSI/RDX, callee-saved registers and stack. Each target/mode is assembled independently with GNU and the native assembler. Native assembler input is reconstructed from current source, not a saved binary.

Also run the existing manifest, `tests/string-fill-perf/check.py` (with `--baseline`), `tests/space/check.py`, `tests/string-cache/check.py`, `tests/string-large-cache/abi.py`, `tests/string-large-cache/mt-abi.py`, `tests/strtran-count/check.py`, and `tests/hasm-relaxation/check.py`.

## Limits

Machine-local performance only; no CPUID-selected ERMS policy, ISA extension, SSE dependency or native Windows performance claim. REP STOSB remains architecturally valid without ERMS but speed is CPU-dependent. Published review evidence reports all losses: small cases can lose against BASE, Space 1 MiB was +0.34% vs Harbour, and unchanged Replicate large controls also lose some samples. The known owned TRY-error cleanup gaps remain; a successful exit alone is not an ownership pass. No new catchability, allocator budget, string header, TLS layout, Dyn, NumLocal or F64 admission.

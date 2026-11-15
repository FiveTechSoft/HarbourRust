# Large one-byte Replicate fills

The one-byte source path now uses the shared fill at every result size, removing only the old8192-byte cutoff. The shared fill already selects small stores or REP STOSB. Multibyte sources keep the existing copy-doubling path. Counts, overflow checks, retention/snapshot rules, allocation, ownership and return ABI do not change.

## Reproduce

Build BASE and candidate with the same rustc flags:

```
rustc --edition=2021 -O -C strip=symbols src/hbc.rs -o /tmp/hbc-new
python3 tests/replicate-large/check.py --compiler /tmp/hbc-new --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/replicate-gate
python3 tests/replicate-large/benchmark.py --compiler /tmp/hbc-new --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/replicate-bench
```

For PE execution add `--wine /path/to/wine --wine-prefix /path/to/prefix` to check.py. Wine is not native Windows. HB is real Harbour hbmk2; review evidence pins it to694428e1c12f726675b19324d62167fa77d68185.

The gate checks raw output with OutStd, not GT's line-wrapped QOut string rendering. It includes all result bytes for NUL/x/255 at counts0,-1,1,7,2047,2048,8191,8192,8193,65536,65537,1048576; empty source; multibyte2/3/257-byte controls; retained-source fixtures and a new one-byte snapshot test whose later count argument replaces the source. Exact before/after output and final hb_memcheck0 wrappers run normal/instrumented on Linux/PE. Five two-worker normal-mode repeats cover NUL65537 and x1MiB. Known owned TRY-error leaks are recorded separately, not counted as ownership passes.

Benchmark defaults use five rotating timed samples plus exact-output warmups for real Harbour, native candidate, native BASE and malloc/memset C. Large64KiB uses300000 calls/sample,1MiB10000. Use `--sizes` to split work into shorter invocations. All process times include startup/shutdown. No CPU pinning or host-noise isolation.

Unchanged multibyte controls use `--source-bytes 2 --sizes 8192,65536 --iterations 20000`, `--source-bytes 2 --sizes 1048576 --iterations 2000`, and `--source-bytes 3 --sizes 8193,65538 --iterations 20000`. Sizes must be divisible by source length. The source is built once outside the timed loop; it consists of repeated A bytes, so the C constant-byte fill yields the same output but is not an equivalent replication algorithm or runtime. Native low-size control samples can be shorter than64KiB headline samples; raw durations are retained.

Also run the full manifest, string-large-cache accounting gate and StrTran regression gate. No new assembler instruction is introduced here; REP STOSB and its GNU/native byte/ABI evidence belong to BASE's shared fill increment.

## Limits

Only the one-byte dispatch is optimized; multibyte copy-doubling unchanged. CPU-local measurements inherit REP STOSB's cross-CPU uncertainty and ABI clear-DF contract. No CPUID policy, numeric/Dyn/F64 admission, allocator budget/header/TLS or general owned TRY-error cleanup change. No native Windows/macOS performance claim. Baseline/control losses remain in the review table rather than being called universal victories.

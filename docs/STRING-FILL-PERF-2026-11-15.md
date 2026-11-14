# PadR / Replicate allocation and copy performance

Apply base: f2e5bf8018c0685266df58aa93c475576655bdfe.
Measured code base: 6a97b3d095cc8ff24561b1e7768865e4096778ea, the retained-source
fix. The sole intervening commit changes README.md only (five lines), with
compiler sources, test fixtures, manifest and runners byte-identical. All
runtime evidence therefore exercises exactly the compiler/test contents of
the apply base; it is not a claim that a new distinct compiler was tested.
This is a separate performance increment. It does not change the emitter's
argument evaluation, snapshot guard, arity, numeric checks or result types.

## Implementation

The exact-capacity reservation/cache path formerly inside hbc_strcpy now
lives in internal hbc_stralloc. Its size cutoff, two-way buckets, unlink before
reuse, capacity/length headers, allocation counters and instrumented registry
registration are unchanged. It returns owned uninitialized bytes; its three
callers fill EVERY byte before exposing the result. This is not an API for
returning arbitrary old heap contents. hbc_strcpy still copies every byte.
The new helper preserves callee-saved registers and aligns nested calls.
No new assembler instruction or system allocator is introduced.

PadR's truncate/full-width/empty branches retain their owned-copy semantics.
The growth branch now uses the cache rather than direct hbc_alloc, copies the
source prefix with rep movsb, then fills the rest with 64-byte unrolled word
stores, 8-byte words and a byte tail. Each store is guarded by remaining length.

Replicate empty/nonpositive-count behavior is unchanged. Count=1 takes the
owned strcpy path instead of a direct OS allocation and scalar loop. Count>1
keeps the existing checked signed length multiplication, uses the same bounded
cache, copies the first source then doubles initialized content with rep movsb.
Each doubling copies min(initialized, remaining), so source and destination
ranges do not overlap. A one-byte source with output below 8192 bytes uses a
repeated-byte word fill; larger outputs use the measured copy-doubling route.
The cutoff is a local measured heuristic, not a universal CPU tuning claim.
Existing x86 direction-flag ABI assumptions apply to rep movsb.

hbc_strfill is a leaf touching only caller-saved rax/rcx/rdi and preserving r10
(the result pointer) and all callee-saved registers. No RC/COW, in-place owner
mutation or release-policy change is added. The source-retention emitter fix
remains intact. Cache capacity/TLS/flush policy is not changed again.

## Fresh correctness evidence

- Complete Linux instrumented manifest: 1729 unique sources, 1729 passes.
- 28 before/after pairs against fresh real Harbour in Linux/PE, normal and
  instrumented, plus 28 wrappers verifying final hb_memcheck 0 after Work
  returns. Both baseline and candidate now must match, unlike the preceding
  correctness package where the old baseline was required to fail.
- These cover the six retained-source control/adversarial programs and one
  all-byte fixture: 252 PadR/Replicate transforms over empty/ASCII/NUL/0xFF data,
  counts around 8/64/128/256, and exact 65535/65536/65537-byte boundaries.
  OutStd compares all returned bytes with Harbour, not just Len/checksums.
  Console QOut wrapping is deliberately not a transform semantic assertion.
- Two concurrent PadR/Replicate worker loops, five normal-mode repetitions,
  with fresh Harbour MT output and per-worker length/interior/tail checks.
  This is bounded schedule evidence, not proof of all concurrency behavior.
- Cache/collision/MT/ERP checker: 49 exact, three named rejections.
- SubStr: 64 exact, 12 named rejections. Trace: 28 exact.
- GNU as/ld builds of the all-byte fixture: two exact Linux executions,
  normal/instrumented, compared to the same fresh Harbour raw output.
- ABI canaries, cache registry (all16 slots) and pre-store overflow helper
  checks pass on Linux and PE Wine.
- Four own caught-error probes still report final memcheck 1. The two SubStr
  probes also remain at 1. These are known limits, NOT successful memory tests.

Fresh oracle: Harbour core 694428e1c12f726675b19324d62167fa77d68185, hbmk2
-gtstd (and -mt for workers). Wine is PE execution, not native Windows. No
native Mac/ARM or unrestricted Harbour compatibility claim. The main
regression manifest and released binaries are not touched.

## Reproduce

Build unmodified BASE as /tmp/hbc-before, apply CHANGES.patch and build as
/tmp/hbc-after using rustc --edition=2021 -O src/hbc.rs. From the repo:

```sh
python3 tests/string-fill-perf/check.py --compiler /tmp/hbc-after \
  --baseline /tmp/hbc-before --hbmk2 /path/to/hbmk2 \
  --wine /path/to/wine --wine-prefix /path/to/prefix \
  --output /tmp/fill-check-new
python3 tests/string-fill-perf/benchmark.py --compiler /tmp/hbc-after \
  --baseline /tmp/hbc-before --hbmk2 /path/to/hbmk2 \
  --output /tmp/fill-benchmark-new
python3 tests/string-retain/benchmark.py --compiler /tmp/hbc-after \
  --baseline /tmp/hbc-before --hbmk2 /path/to/hbmk2 \
  --output /tmp/count1-benchmark-new
rustc --edition=2021 -O tools/run_native_manifest.rs -o /tmp/run-manifest
/tmp/run-manifest --compiler /tmp/hbc-after --target linux \
  --manifest tests/manifest.txt --output /tmp/fill-full-new
```

The existing cache/SubStr/trace checkers accept --compiler, --hbmk2, --wine,
--wine-prefix, --output. Output directories must be new. Existing helper
shell tests need ./hbc plus their documented M/MLIB/WINE/WINEPREFIX setup.
The new checker depends on the retained-source fixtures already in BASE.

## Performance interpretation

Tables below are median ns/call of three whole-process samples. Exact stdout
is verified each time for baseline/candidate/Harbour/C. No other validation
workload was launched by this task during the benchmark. The machine is not
a dedicated performance host; scheduler/thermal/load variation remains.
Process launch/shutdown is included and short cases are especially noisy.
A faster/lower sample is not an application-wide speedup guarantee.

The first table measures actual PadR growth and Replicate count>1, including
non-power-of-two source/count combinations. C implements malloc + memcpy /
memset / bounded copy-doubling for the same returned bytes. It does not model
the VM, instrumented registry, cache or argument-retention ownership.
The second table preserves the preceding same-source full-width/count1 and
count-call benchmark. Its C malloc/memcpy reference copies once and does not
simulate the extra retained argument or user function call. Do not present
that reference as equivalent runtime work or physical bytes moved.

### Growth / repetition

| Function | Source bytes | Width/count | Before | After | Harbour | C |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| PadR | 2 | 8 | 4998.47 | 16.63 | 266.14 | 16.18 |
| Replicate | 1 | 8 | 5013.86 | 14.90 | 170.11 | 19.55 |
| PadR | 64 | 256 | 5739.38 | 18.57 | 176.88 | 30.13 |
| Replicate | 1 | 256 | 5441.21 | 18.95 | 249.76 | 172.15 |
| Replicate | 32 | 8 | 5526.16 | 63.20 | 221.66 | 84.22 |
| PadR | 1024 | 4096 | 8933.21 | 193.22 | 339.90 | 230.57 |
| Replicate | 1 | 4096 | 11299.30 | 132.84 | 633.32 | 318.00 |
| Replicate | 512 | 8 | 11708.53 | 98.71 | 744.08 | 306.56 |
| PadR | 16384 | 65536 | 55359.12 | 2678.36 | 2989.65 | 2111.15 |
| Replicate | 1 | 65536 | 75127.99 | 1657.92 | 2418.88 | 2612.66 |
| Replicate | 8192 | 8 | 80706.77 | 1906.23 | 2645.12 | 2574.78 |
| Replicate | 3 | 5 | 5176.44 | 132.38 | 389.97 | 50.76 |
| Replicate | 257 | 17 | 8649.44 | 109.32 | 453.33 | 291.42 |
| PadR | 257 | 4095 | 7130.96 | 257.76 | 333.40 | 201.56 |

### Full-width / count1

| Function | Count call | Result bytes | Before | After | Harbour | C |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| PadR | False | 8 | 19.43 | 19.58 | 191.61 | 13.34 |
| PadR | False | 256 | 25.44 | 34.05 | 176.14 | 21.23 |
| PadR | False | 4096 | 61.07 | 92.45 | 338.07 | 146.19 |
| PadR | False | 65536 | 2546.91 | 2177.52 | 1484.34 | 3086.48 |
| PadR | True | 8 | 25.44 | 40.07 | 168.10 | 19.81 |
| PadR | True | 256 | 43.50 | 42.00 | 187.68 | 20.64 |
| PadR | True | 4096 | 99.38 | 107.78 | 333.80 | 139.57 |
| PadR | True | 65536 | 3740.53 | 3827.81 | 1519.55 | 3002.68 |
| Replicate | False | 8 | 5250.94 | 17.56 | 169.21 | 12.54 |
| Replicate | False | 256 | 5125.53 | 22.80 | 170.98 | 19.77 |
| Replicate | False | 4096 | 7763.96 | 67.89 | 431.02 | 147.75 |
| Replicate | False | 65536 | 71758.11 | 1858.43 | 1473.65 | 2307.28 |
| Replicate | True | 8 | 5004.15 | 55.29 | 163.56 | 12.76 |
| Replicate | True | 256 | 5377.26 | 71.11 | 195.93 | 21.19 |
| Replicate | True | 4096 | 8739.73 | 127.05 | 254.29 | 210.73 |
| Replicate | True | 65536 | 94069.12 | 4373.42 | 1366.07 | 2684.82 |

### Shared strcpy path control

The existing same-source SubStr allocation/copy benchmark also ran on the
same before/after binaries, since it uses the factored helper.

| Bytes | Before | After | Harbour | C |
| ---: | ---: | ---: | ---: | ---: |
| 8 | 26.62 | 55.96 | 216.96 | 19.66 |
| 64 | 81.74 | 113.71 | 165.00 | 13.88 |
| 256 | 47.58 | 62.86 | 290.52 | 22.96 |
| 4096 | 143.32 | 101.02 | 252.41 | 149.41 |
| 65536 | 3380.34 | 3368.17 | 1002.70 | 2427.36 |

## Limits

The major win is removal of repeated OS allocations in cache-eligible PadR
growth / Replicate paths. This does not prove all string APIs are fast.
Some C cases are faster. Full-length 64KiB PadR/Replicate count1 and the
count-call retained variants still lose to Harbour without RC/COW. Sharing
reservation adds an internal call to strcpy; some already-fast paths cost
more ns in samples. Timing differences in unchanged emitter paths are not
claimed code improvements. Do not pick only winning rows from these tables.

The cache still has eight two-way exact-capacity buckets, up to 64KiB per
entry and up to 1,048,832 retained bytes including headers per thread. Outputs
above the cutoff or competing capacities can still require OS allocations.
No cache size, thread-local layout or flush policy is enlarged in this patch.
Returned values remain independent owned strings, not borrowed aliases.

Existing TRY owned cleanup is absent. A count error can leak the retained
source exactly as before; four own probes and two SubStr probes report this
separately. Normal-path final memcheck0 is not exception-safety proof. Static,
byref, aggregates, codepage/Unicode, arbitrary numeric counts, RC/COW and
sequence/thread admission are not expanded. Instrumented MT remains rejected.
Wine is not native Windows, and no native macOS/ARM run is claimed. This
patch changes neither the main manifest nor released compiler binaries.

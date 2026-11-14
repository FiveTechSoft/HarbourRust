# Bounded string cache and copy increment

Base: `85d46c6514514bcd372404e05f6e2beb201520e3` (ERP corrections).

This changes allocation/copy helpers, not SubStr's emitter or snapshot rules.
The exact-capacity free-block cache has eight two-way buckets. Only logically
freed strings up to 65,536 bytes are eligible. A reused block is removed from
the cache before becoming live. Headers, ownership, logical allocation/free
counts and instrumented registry checks retain their current meaning.
A full bucket still releases the block through the existing OS path.

Sixteen pointers replace eight; the cache retains at most 16 * 65,552 bytes
including headers per thread. Both flush routines visit all sixteen slots.
The existing thread-local cache pointer moves from offset 56 to offset 128
inside the same 256-byte TLS region, leaving the thread-block pointer at 120
intact. Cache bytes occupy 128..255. The nonthreaded cache reserves 128 bytes.
This is not a new shared process cache or a change to thread ownership.

String copies of at least 128 bytes use `rep movsb`; smaller copies keep the
current byte loop. Existing x86-64 ABI direction-flag assumptions apply.
The source and destination of this owned copy are distinct allocations.
No platform API, array/hash allocator, return type, string tag, SubStr
snapshot decision, stack reserve or released compiler binary is changed.

## Evidence

Fresh Linux instrumented manifest on this base: 1729/1729, unique sources.
SubStr checker: 64 exact
normal/instrumented Linux/PE Wine successes, 12 named rejections; the two
caught-error ownership probes still report final hb_memcheck 1 separately.
A capacity/byte-content fixture covers 0, 1, 7, 8, 9, 127, 128, 129, 255, 256,
257, 4095, 4096, 65535, 65536 and 65537 bytes on Linux/PE Wine in both modes.
A wrapper releases all owners and checks final hb_memcheck 0 in all four
variants. A repeated collision/reuse fixture checks 4096/8192/12288/65536-byte
strings and their first/last bytes, also with a final memcheck 0 wrapper.
A two-worker string-copy loop ran five times in normal mode; fresh real Harbour
MT output matches. Instrumented MT remains a named rejection. The fixed ERP
fixtures also pass 28 fresh exact Linux/PE comparisons and two named
NumLocal rejections. Total for the new checker: 49 exact executions and
three named rejections. TRY trace regression: 28 further exact comparisons.
GNU as/ld: six exact Linux capacity/collision checks, in both modes.
The MT fixture is a bounded concurrency probe, not proof of every schedule. No native Windows/macOS run is claimed.

The benchmark runner is independent of the regression manifest:

```sh
python3 tests/string-cache/check.py --compiler ./hbc-new \
  --hbmk2 /path/to/hbmk2 --output /tmp/cache-check \
  --wine /path/to/wine --wine-prefix /path/to/prefix
python3 tests/string-cache/benchmark.py --compiler ./hbc-new \
  --baseline ./hbc-old --hbmk2 /path/to/hbmk2 --output /tmp/cache-benchmark
```

It compiles the same SubStr program with baseline, candidate and Harbour,
plus an owned-copy malloc/memcpy C reference. Outputs match exactly before
reporting median of three whole-process samples. Launch/shutdown time is
included, making very short samples noisy. These are synthetic loops, not
an application-wide speedup or a library-completion claim.

Measured ns/call on the validation host, same corrected base before/after,
with no simultaneous validation workload launched by this task:

| Bytes | Baseline HR | Candidate HR | Harbour | C malloc/memcpy |
| ---: | ---: | ---: | ---: | ---: |
| 8 | 5187.24 | 23.11 | 181.99 | 12.96 |
| 64 | 5355.27 | 105.54 | 184.46 | 15.99 |
| 256 | 5183.52 | 38.60 | 184.17 | 20.41 |
| 4096 | 21238.53 | 98.02 | 236.23 | 143.26 |
| 65536 | 144531.38 | 3817.13 | 1128.50 | 2482.92 |

The 64 KiB full-length result still loses: Harbour may retain a shared full
string without copying, while this owned path makes independent source and
result copies. This does not add reference counting or copy-on-write. Do not
hide that gap or compare its MB/s as if each implementation moved the same
number of physical bytes. Future Left/Right partial/full benchmarks remain
separate work. The unpublished Left/Right experiment is not in this patch.

## Limits

Existing exception-path owned leaks, finite cache capacity, exact-capacity
collisions and unrelated runtime/target limits remain. Results above were
measured afresh on the named corrected base. The ERP regression gate is
retained, but this does not repair other pre-existing borrowed-source
mutation paths (PadR/Replicate/CToD follow-up), general TRY owned cleanup,
or codepage/Unicode semantics. No current-tip pass beyond this base is implied.

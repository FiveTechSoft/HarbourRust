# String concat benchmark (sonda, NOT upstream) - evidence record

Iteration 63f paired measurement, string `+` accumulation loop.
This is a LABELED PROBE written for measurement, not an upstream
Harbour example. Correctness first: both programs do the same work
(19999 concatenations, final string length 20000) and both print
20000 before timing matters.

## Sources

HarbourRust idiom (bench_cat_hr.prg) - `local s := "" + "x"` because
this PoC requires an initializer expression:

```
function main()
   local s := "" + "x"
   for i := 1 to 19999
      s = s + "x"
   next
   ? len( s )
   return
```

Harbour idiom (bench_cat_hb.prg):

```
function main()
   local s := "x"
   for i := 1 to 19999
      s := s + "x"
   next
   ? len( s )
   return
```

## Build (exact commands / flags)

- HarbourRust: `hbc bench_cat_hr.prg out.s && as out.s -o out.o && ld out.o -o bc_hr`
  (hbc = iteration 63f, built with `rustc --edition 2021 -O src/hbc.rs`)
- Harbour: `hbmk2 -gtstd bench_cat_hb.prg -obench_cat_hb`
  (-gtstd = no terminal driver, same as the oracle probes)

## Versions

```
rustc 1.99.1 (58cf8f9c3 2026-10-13)
Harbour Make (hbmk2) 3.2.1dev (r2026-10-24 21:11)
Copyright (c) 1999-present, Viktor Szakats
```
hbc: HarbourRust iteration 63f (HEAD ed3bb916a9d131e6a80b97b2b6df191c2d6db71d)
harbour-core pinned at 694428e1c12f726675b19324d62167fa77d68185

## Binary SHAs (sha256)

- HarbourRust binary: 73175ea763c260b1563301cff79e463b132220896a219d51a7336c775990a23e
- Harbour binary:     d03b02c24d51da16521c3f7c203f49f20efd23f1b40cf9be87270de1124ee00a

## Protocol

Same machine, same moment, binaries only (no compilers in the loop).
3 warmup + 21 timed runs per side, wall-clock per process via
python perf_counter_ns; median with min/p95. N=20000 (final length).

## Raw results, N=20000 (ms, sorted)

```
harbourrust N=20000 3warm+21timed median=148.75 min=129.25 p95=172.35
  raw: 129.25, 129.79, 131.52, 131.76, 132.58, 138.32, 139.54, 140.75, 142.20, 144.76, 148.75, 149.15, 150.57, 152.86, 154.22, 156.92, 157.78, 159.69, 166.50, 172.35, 195.55
harbour N=20000 3warm+21timed median=2.54 min=2.40 p95=2.82
  raw: 2.40, 2.40, 2.48, 2.49, 2.50, 2.51, 2.51, 2.52, 2.52, 2.53, 2.54, 2.56, 2.58, 2.60, 2.62, 2.63, 2.66, 2.77, 2.82, 2.82, 2.85
```
(An earlier same-protocol round on the same binaries gave 158.7 vs 2.5 ms;
both rounds agree within run-to-run spread.)

## Scaling check (11 runs per point, median ms)

```
N, impl, median_ms, min_ms, all_runs_ms
10000, harbour, 2.33, 2.18, [2.2, 2.2, 2.2, 2.3, 2.3, 2.3, 2.3, 2.4, 2.4, 2.6, 2.7]
10000, harbourrust, 51.05, 44.87, [44.9, 45.7, 46.0, 46.0, 49.2, 51.1, 51.3, 51.5, 52.3, 53.0, 55.6]
20000, harbour, 2.37, 2.33, [2.3, 2.3, 2.3, 2.4, 2.4, 2.4, 2.5, 2.5, 2.5, 2.5, 2.8]
20000, harbourrust, 136.70, 124.54, [124.5, 126.0, 126.2, 128.5, 130.7, 136.7, 148.9, 156.3, 160.7, 162.3, 171.9]
40000, harbour, 3.06, 3.02, [3.0, 3.0, 3.0, 3.0, 3.1, 3.1, 3.1, 3.1, 3.2, 3.2, 3.3]
40000, harbourrust, 457.12, 415.72, [415.7, 423.2, 437.0, 448.0, 456.3, 457.1, 488.4, 500.2, 501.0, 517.4, 530.4]
```
Harbour: 2.33 / 2.37 / 3.06 ms for N = 10k / 20k / 40k - flat to linear.
HarbourRust: 51.1 / 136.7 / 457.1 ms - x2 work multiplies time ~x2.7-3.3,
i.e. quadratic in N.

## Attribution (measured + source-grounded, not inferred from timings alone)

1. Measured: Harbour scales ~linearly, HarbourRust scales quadratically
   (table above).
2. HarbourRust side: each concat is hbc_strcat = one mmap/munmap pair
   (~100 ms of sys time at N=20000, `time` output) plus a full copy of
   both operands each iteration -> O(n^2) bytes copied.
3. Harbour side (pinned harbour-core sources):
   - src/vm/hvm.c hb_vmPlus() string branch (line ~3317): moves the LHS
     buffer into the result item (hb_itemMove, no copy), then
     hb_itemReSizeString() + hb_xmemcpy of ONLY the appended operand
     (nLen2 bytes).
   - src/vm/itemapi.c hb_itemReSizeString() (line 2111): on growth it
     allocates nSize+1 PLUS nSize extra when the old capacity is
     exceeded - capacity doubling, so appends are amortized O(1) and the
     loop is O(n) total; hb_xRefResize handles the shared-refcount case.
   Both match the measured linear scaling.

Conclusion: Harbour is ~63x faster on this loop (median 148.7 vs 2.5 ms
at N=20000) because it appends in place with amortized growth while this
PoC copies everything through a fresh mmap per concat. Optimization
targets, in priority order: (1) replace per-alloc mmap/munmap with a
small buffer allocator in the emitted runtime (~60% of the time),
(2) move-LHS + grow + append for the assign-back-to-same-var pattern,
preserving value semantics (removes the O(n^2)). Neither changes
alias/copy/ownership rules; each lands as its own verified iteration
with a re-run of this probe.

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

---

## Round 3 (iteration 63h): in-place grow for the assign-back pattern

What changed in 63h:

- String layout: 16-byte header {capacity at -16, length at -8}; fresh
  copies (hbc_strcpy/hbc_strcat) start with cap == len; hbc_freestr frees
  the new layout; all string frees migrated (runtime + ABI harness).
- NEW hbc_strgrow: appends into an owned buffer in place when capacity
  allows, doubling realloc (freeing the old block itself) when not.
- Codegen emits it for `s := s + rhs` on a plain owned local only when
  rhs does not mention s and contains no calls (calls stay excluded
  until byref/global/nested effects are reconciled). All other forms
  keep the hbc_strcat copy semantics.

Correctness: battery 647/647 + ABI harness, Linux and Wine, including
six dedicated grow/freestr tests with hb_memcheck() counts (content
equality against the strcat path, realloc fallback on a single append
larger than spare capacity, excluded-call fallback, self-alias
fallback, rhs-local grow, hash key replace under the new layout) and a
byref append loop (hk238: a `@` string param plus `for` crashed on a
frame-slot collision; fixed).

Measurement (same protocol, same machine and moment, same preserved
Harbour binary sha256 d03b02c2...):

- N=20000 (19999 appends, final length 20000), 3 warmup + 21 timed,
  two samples: HarbourRust median 0.29 / 0.28 ms (min 0.28 / 0.25)
  vs Harbour 2.54 / 2.18 ms (min 2.38 / 2.11). Before the fix:
  148.75 ms. At this size both sides are dominated by process
  startup, so read this as TOTAL time for the whole probe, not as an
  engine comparison.
- Work-dominated sizes (11 runs, median ms): N=200000: HarbourRust
  0.99 vs Harbour 10.94; N=400000: HarbourRust 1.51 vs Harbour 23.66.
  Both now scale ~linearly: amortized O(n) appends on both sides.
  Derived per-append marginal cost from these two points:
  HarbourRust ~2.6 ns vs Harbour ~64 ns (derived, not directly timed).
- Raw runs: sondas raw21_r3_n20000.txt and scaling_r3_large.txt;
  binary/asm SHAs in r3_sha.txt.

Rounds 1-2 above are preserved unchanged: each timing round is its own
record.

### Round 3 raw evidence (preserved in-repo)

Probe shape at every N (Harbour idiom `s := s + "x"`, HarbourRust idiom
`local s := "" + "x"` then `s = s + "x"`; N = final length, loop runs
N-1 times; the N=20000 sources are in the round 1-2 section above):

Harbour N=200000 (same shape at 400000):

```
function main()
   local s := "x"
   for i := 1 to 199999
      s := s + "x"
   next
   ? len( s )
   return
```

HarbourRust N=200000:

```
function main()
   local s := "" + "x"
   for i := 1 to 199999
      s = s + "x"
   next
   ? len( s )
   return
```

Build flags: Harbour `hbmk2 -gtstd <src> -o<name>`; HarbourRust
`hbc <src> out.s && as out.s -o out.o && ld out.o -o <name>`
(hbc = iteration 63h, `rustc --edition 2021 -O src/hbc.rs`).

Raw runs, N=20000 (ms, sorted, 3 warmup + 21 timed):

```
harbourrust-r3 N=20000 3warm+21timed median=0.28 min=0.25 p95=0.41
  raw: 0.25, 0.26, 0.26, 0.26, 0.26, 0.27, 0.27, 0.27, 0.27, 0.28, 0.28, 0.28, 0.28, 0.29, 0.31, 0.32, 0.34, 0.34, 0.40, 0.41, 0.43
harbour N=20000 3warm+21timed median=2.18 min=2.11 p95=2.48
  raw: 2.11, 2.12, 2.13, 2.13, 2.14, 2.14, 2.15, 2.15, 2.16, 2.17, 2.18, 2.26, 2.29, 2.29, 2.30, 2.34, 2.39, 2.43, 2.44, 2.48, 2.57
```

Raw runs, work-dominated sizes (11 runs each; columns
N, impl, median_ms, min_ms, all_runs_ms):

```
200000, harbourrust-r3, 0.99, 0.91, [0.91, 0.94, 0.94, 0.96, 0.96, 0.99, 1.02, 1.06, 1.07, 1.11, 1.16]
200000, harbour, 10.94, 10.35, [10.35, 10.42, 10.59, 10.63, 10.74, 10.94, 10.99, 10.99, 11.21, 11.71, 13.60]
400000, harbourrust-r3, 1.51, 1.33, [1.33, 1.40, 1.40, 1.43, 1.47, 1.51, 1.58, 1.58, 1.58, 1.61, 1.71]
400000, harbour, 23.66, 19.60, [19.60, 20.78, 22.27, 22.41, 22.93, 23.66, 24.12, 24.20, 24.38, 24.66, 24.97]
```

Binary/asm SHAs (sha256) for the round 3 binaries and the Harbour
binary reused from rounds 1-2:

```
6ffe7490a1404b3bf2d148c9946a2ac3b5601b5396748e10abff9677e2434d37  /tmp/r3.s
82be2a13b5165055a8a84306f241812534732c798eeb64de35e5d02f4131c83b  /tmp/bc_hr_r3
d03b02c24d51da16521c3f7c203f49f20efd23f1b40cf9be87270de1124ee00a  bc_hb.bin
a95622ab9f0755377ae09e870742ae2fc2a62997dfbe66f9648704dc9376d852  bhr_r3_200000
c8dbd17fd95cf102fafc3035ae0765464173e3838718e3c918cbb128fa6419fc  bhr_r3_400000
2df7bda51bf20c468e36cfaf360e4236ffd43a633767cf16ae49826c87384abb  bhb_200000
af9877e2a3cee873b4b68e13dcc606675f2786bdba4f0022103684109806f13d  bhb_400000
```

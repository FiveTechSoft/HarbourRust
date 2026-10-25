# Benchmark results (median of 5 runs, Linux x86-64, 2 cores / 2 GB)

Execution time (ms):

| program  | Harbour pcode | Harbour -gc3 | HarbourRust | vs pcode | vs -gc3 |
|----------|---------------|--------------|-------------|----------|---------|
| b1_int   | 12348         | 8214         | 198         | 62x      | 41x     |
| b2_str   | 990           | 807          | 406         | 2.4x     | 2.0x    |
| b3_call  | 1735          | 1136         | 38          | 46x      | 30x     |

Optimization contrast on the Harbour side (median ms; baseline already -O3):

| program  | pcode -O2 | gc3 -O2 | gc3 -O3 -march=native |
|----------|-----------|---------|------------------------|
| b1_int   | 12597     | 8131    | 8225                   |
| b2_str   | 976       | 829     | 849                    |
| b3_call  | 1768      | 1075    | 1111                   |

Explicit optimization variants move Harbour times by at most ~5% in either
direction; the speedup columns above are unaffected.

Compile time, source to binary (median of 5, ms): HarbourRust 9 (hbc+as+ld),
hbmk2 106-134 depending on program and mode. Front-end alone: hbc 4 ms,
harbour 3 ms - at parity; the end-to-end difference comes from the C
round-trip through gcc, and on these tiny programs it is indicative only.

Observations: the gain is largest where VM dispatch dominates (integer loop,
call overhead) and smallest for string comparison, where both sides spend
most of the time comparing bytes. No profiling was done, so no claim is made
about where Harbour spends its time beyond that.

## Post-QOut re-run (2026-10-25, HEAD ca760e0a)

Same frozen config: same three programs byte-for-byte, same binaries for
Harbour (pcode / -gc3, hbmk2 default -O3 baseline), HarbourRust rebuilt
from HEAD with the same hbc+as+ld path. Median of 5 runs, same machine.

| program  | Harbour pcode | Harbour -gc3 | HarbourRust | vs pcode | vs -gc3 |
|----------|---------------|--------------|-------------|----------|---------|
| b1_int   | 11471         | 7533         | 171         | 67x      | 44x     |
| b2_str   | 865           | 745          | 520         | 1.7x     | 1.4x    |
| b3_call  | 1591          | 972          | 33          | 48x      | 29x     |

Correctness gates before timing: b2_str and b3_call outputs are
BYTE-IDENTICAL to both Harbour configs (sha256 verified). b1_int is
category DIVERGE-NUMERIC: the accumulator escapes int64 by design of the
source (the once-per-iteration subtraction cannot bound it), Harbour
continues in double (value rounding + 20-column float field) while
HarbourRust wraps in i64 with the integer field rule - the timing
comparison stands (same source text), the outputs differ by the
registered numeric model. The earlier "200 runs of arith, 50ms vs 269ms"
figure was a spot check, not part of this benchmark series; this table is
the current benchmark data.

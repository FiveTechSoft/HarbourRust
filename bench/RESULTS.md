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

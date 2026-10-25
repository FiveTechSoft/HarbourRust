# Benchmark results (median of 5 runs, Linux x86-64, 2 cores / 2 GB)

Execution time (ms):

| program       | Harbour pcode | Harbour -gc3 | HarbourRust | vs pcode | vs -gc3 |
|---------------|---------------|--------------|-------------|----------|---------|
| b1_int        | withdrawn     | withdrawn    | withdrawn   | -        | -       |
| b2_str        | 990           | 807          | 406         | 2.4x     | 2.0x    |
| b3_call       | 1735          | 1136         | 38          | 46x      | 30x     |
| b1b_int_bounded | 14050       | 14224        | 251         | 56x      | 57x     |

b1_int is WITHDRAWN as a speed comparison (see the correction section
below): Harbour runs its accumulator in double while HarbourRust runs it
in i64, so the two sides do different numeric work per iteration and the
timings are not comparable. b1b_int_bounded is the bounded replacement
case with equal semantics on both models.

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
| b1_int   | 11471         | 7533         | 171         | withdrawn | withdrawn |
| b2_str   | 865           | 745          | 520         | 1.7x     | 1.4x    |
| b3_call  | 1591          | 972          | 33          | 48x      | 29x     |

Correctness gates before timing: b2_str and b3_call outputs are
BYTE-IDENTICAL to both Harbour configs (sha256 verified).

b1_int correction (supersedes the earlier rationale, which claimed the
accumulator "escapes int64" and HarbourRust "wraps in i64"): both claims
were wrong. The accumulator reaches 4900499752500003, which fits in i64;
no wrap occurs and both sides print the same 16 digits. The real
divergence is the numeric type path: probe evidence (printing the value
computed at runtime vs the same value as a literal) shows Harbour's
runtime accumulator is a DOUBLE, printed in a 20-wide field, while the
same digits as an integer literal print 17-wide; HarbourRust keeps i64
and prints 17-wide. Because the two sides execute different arithmetic
per iteration (double vs int64), the same source text does not make the
timings comparable, and b1_int is withdrawn from all speedup claims.
The earlier design note that described the accumulator as bounded below
2e6 was also wrong: the once-per-iteration subtraction of 1000003 cannot
keep up once the loop index exceeds 1000003, so the accumulator grows to
about 4.9e15.

Original source preserved unchanged: bench/b1_int.hb, sha256
b2aa4c6cb0768dbd40da3ff16890ce892f71dec3af677c2030ec5559e4e6b101
(frozen 2026-10-25 08:08 CET).

## Replacement bounded case: b1b_int_bounded

New versioned program bench/b1b_int_bounded.hb; the original b1_int.hb is
untouched. A second reset guards the accumulator once the loop index
exceeds the subtraction constant, so the accumulator stays below
101000000 (< 2^31) at all times: Harbour and HarbourRust both run the
whole loop in integer arithmetic with identical semantics. Output is
byte-identical on all three binaries ("\n" + 9 spaces + "0", verified
with od). Same frozen config and method as above: hbmk2 default (-O3
baseline), HarbourRust rebuilt from HEAD, median of 5 runs, same
machine. Results are in the first table.

The earlier "200 runs of arith, 50ms vs 269ms" figure was a spot check,
not part of this benchmark series; the tables above are the current
benchmark data.

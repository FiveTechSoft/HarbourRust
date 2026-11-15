# Compile-time scaling profile, 14 Nov 2026

Question: the ERP evaluation reported compile time growing roughly x3 for
each x2 of source size. Measured against the current compiler this note
records where time goes and what changed.

No publication is part of this note. The probe sources are generated in
`work/` and are not committed.

## Method

Two synthetic sources, both compiled for Windows with the internal PE
writer (`hbc <src> <out> --target=windows -I tests`):

- `stmts_N`: one function containing N statements `i := i + k` with a
  single `? i` at the end.
- `scale_N`: three literal arrays of N integers.

Sizes double from 1000 to 16000 (statements) and 4000 to 32000 (arrays).
Timings are wall-clock `time` on Windows 11 x86-64 with the native battery
running concurrently in another shell; they are single-machine samples,
not a benchmark suite. A timer-instrumented compiler build reports phase
boundaries (preprocess, parse, check, emit, assembler parse, assembler
finish) and assembler counters (text items, `encode_all` calls,
instruction encodes, numeric-label scans).

## Where the time goes

Front end is linear and small: at 16000 statements the preprocess, parse,
type-check and assembly-emission phases together take under 0.5 s.

The assembler dominates. Each compile performs a constant 40 full
re-encodes of the whole text (38 jump-relaxation iterations plus two PE
finalization encodes), independent of source size. Instruction encoding
itself gets slower per item as the text grows:

| statements | text items | instruction encodes | encode time | per encode |
|---|---|---|---|---|
| 2000 | 33253 | 4.93M (at 8000) | - | - |
| 8000 | 123253 | 4930080 | 6.3 s | 1.29 us |
| 16000 | 243253 | 9730080 | 22.3 s | 2.29 us |

A linear scan over numeric-label definitions was ruled out: calls and
scan length stay constant (25829 calls, 84807 scanned entries) at 8000
and 16000 statements. The growth is the repeated full-text passes; the
observed per-item slowdown is consistent with memory effects.

## What the upstream relaxation change bought

`b0ee722` (branch-shortening trials proved impossible skipped by size
bounds) reduced same-machine wall time about fivefold on the
statement-heavy source and about 4.5x on large literal arrays:

| source | before b0ee722 | after |
|---|---|---|
| stmts 2000 | 5.46 s | 1.14 s |
| stmts 4000 | 13.65 s | 2.72 s |
| stmts 8000 | 37.47 s | 7.39 s |
| stmts 16000 | not measured | 29.0 s |
| scale 4000 | 3.49 s | 0.78 s |
| scale 8000 | 6.55 s | 1.44 s |

Production spot checks on the final build of this note (76d027c):
scale 4000/8000/16000 = 0.80/1.46/2.83 s, stmts 2000/4000 = 1.29/3.15 s.

The per-doubling factor is now about 2.4-2.8x for the statement source
and about 1.85x for literal arrays (near-linear).

## Discarded prototype

An allocation-free encoder (`encode_ins_into` writing directly into the
text buffer, positions made absolute) produced byte-identical PE output
(timestamp/checksum fields normalized) and byte-identical ELF output on
a six-program corpus, and the accumulator fixture still passed. Wall
time moved by at most 7% at 8000 statements and not measurably at
16000, so per-instruction buffer allocation is not the bottleneck; the
prototype was discarded rather than committed.

Further gains require caching encoded instruction templates across
relaxation passes, not micro-optimizing allocation.

## Limits

Measured on one Windows machine while other work ran in parallel. The
statement and array generators are synthetic, not ERP sources. The
assembler timings use an instrumented build; instrumentation overhead
is included in its wall times but not in production numbers. No claim
is made about other hosts or about minimum-layout (GNU as parity)
changes.

## Follow-up, 15 Nov 2026: encoding cache and O(1) label offsets

Two assembler changes landed after the measurements above.

1. Layout-free instruction cache (`8dbd7a8`): instructions whose operands
   are numeric-only, with no RIP label, branch or call, encode once and
   are reused by all relaxation passes. Literal-array sources compile
   2.3x-2.6x faster; statement-heavy sources 4%-17% faster.
2. Precomputed section prefixes (this change): `loc_offset` recomputed
   the prefix sum over all data items for every symbol reference. The
   16000-statement source scanned 16.5 billion prefix entries. Resolver
   construction now builds cumulative offsets once per pass, making each
   lookup O(1). Alternating timings: 8000 statements 9.0-10.5 s ->
   2.0-3.3 s; 16000 statements 33.2-34.7 s -> 3.6-3.8 s, about 9x.
   Literal-array sources are cache-bound and stay near 0.8 s/1.3 s.

Both produce byte-identical PE output (timestamp/checksum normalized)
and byte-identical ELF on the comparison corpus. The per-doubling factor
for the statement source is now near 1.1x in this range.

## Follow-up, 15 Nov 2026: one type query per Bin operand

`expr_ty`'s Bin arm recomputed both operand types in every branch
(up to six recursive calls per node). Left-associative arithmetic chains
therefore grew exponentially: the f64 call-chain fixture (t770) issued
26 million type queries at 12 factors and compiled in 103 s.

Hoisting the two operand types into locals keeps semantics identical
(byte-identical PE/ELF on the comparison corpus) and compiles t770 in
1.3 s on this machine, about 80x faster.

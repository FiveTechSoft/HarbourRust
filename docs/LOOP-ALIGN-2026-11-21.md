# Promoted loop heads aligned to 32 bytes (21 November 2026)

**Status: draft, not a fix.** Head alignment helps one benchmark and is
neutral on three, but on another loop body it made things worse. It is not
a mitigation for the layout effect described below; see "What it does not
do".

## Change

`src/loopreg.rs` now puts `.p2align 5` before the head label of every loop
it promotes to registers. The internal assembler (`src/hasm.rs`) already
pads `.p2align` in `.text` with the GAS NOP table, GNU as does the same with
`--external-as`, and the Mach-O ARM64 translator ignores text alignment.

The head is reached only by fall-through from outside the loop (a
promotion rule), so the padding NOPs run once per loop entry, not per
iteration. The directives are inserted after all promotions: a directive
inside a loop body keeps the enclosing loop from qualifying, and the
inner loop's alignment must not change whether the outer loop is promoted.
`--no-loopreg` turns this off as well.

## Measured on main

Process cycles and CPU time on native Windows 11 (Xeon W-2140B, Skylake),
minimum of 7 runs. Both are measured on the same binary, so they rule out
timing noise but not layout effects.

| loop | before | after | change |
|---|---|---|---|
| `s := s + i * k - 1` with a conditional subtract, 500 M | 4.54 G | 3.71 G | -18 % |
| `bench/b1_int.prg` at 800 M | 4.28 G | 4.29 G | 0 % |
| `bench/b1b_int_bounded.prg` at 800 M | 5.44 G | 5.43 G | 0 % |
| `bench/b3_call.prg` (not promoted) | 3.15 G | 3.15 G | 0 % |

## What it does not do

This CPU is affected by the JCC erratum: a jump that crosses or ends on a
32-byte boundary runs slowly. Aligning the head fixes where the loop
starts, but each jump inside the body still lands wherever the body's
length puts it. With a different body (the per-statement overflow stubs
stacked on #15), the same alignment made `b1b_int_bounded` slower,
5.83 G → 8.01 G. Assembling instead with GNU as
`-mbranches-within-32B-boundaries`, which pads each jump, gave the fast
figure in every variant tried: 3.74 G, 4.31 G and 5.49 G for the three
promoted loops on main.

The robust form is jump padding in the internal assembler, the same thing
GNU as does. It would change the bytes of every x86 binary and grow the
code, and it pays off only on CPUs affected by the erratum. That is a
decision for the maintainers; this branch does not do it.

## Verification (native Windows 11)

- Manifest differential against main (9955a049), Windows, Linux and Windows
  `--instrument` assembly of 1894 programs: no compile result changes; 13
  rows change. In each the only difference is the added `.p2align 5`
  lines, 17 in all: the same 17 loops in 13 rows that loop register
  promotion already covers.
- Those 13 rows built and run on Windows by both compilers, plain and
  `--instrument`: stdout, stderr and exit status identical.
- `rustc --test`: loopreg tests updated for the directive, plus one test
  showing that nested loops are both promoted and both aligned. The 2
  `llvm_darwin` failures are the Windows CRLF ones that #14 fixes.
- CI gates pass on Linux and Windows. A macOS dispatch on this branch
  reports `PASS 1322, REJ 1` on both Mac targets; the REJ is the named
  rejection already on main.

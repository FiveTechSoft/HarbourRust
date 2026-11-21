# Promoted loop heads aligned to 32 bytes (21 November 2026)

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

## Why

On this machine (Xeon W-2140B, Skylake, affected by the JCC erratum) a
tight loop's speed depends on where its code lands. The same promoted
loop ran 1.22x slower in the default layout than with its head aligned.
Aligning the head gave the same result as GNU as with
`-mbranches-within-32B-boundaries`: 3.71 G cycles each for the first loop
below, 5.60 G each for `b1_int` with the overflow check from #15.

## Cost and gain

Process cycles and CPU time on native Windows 11, minimum of 7 runs. The
two methods agree.

| loop | before | after | change |
|---|---|---|---|
| `s := s + i * k - 1` with a conditional subtract, 500 M | 4.54 G | 3.71 G | -18 % |
| `bench/b1_int.prg` at 800 M | 4.28 G | 4.29 G | 0 % |
| `bench/b1b_int_bounded.prg` at 800 M | 5.44 G | 5.43 G | 0 % |
| `bench/b3_call.prg` (not promoted) | 3.15 G | 3.15 G | 0 % |

With the overflow check of PR #15 on top, the first loop goes from
5.76 G to 4.73 G, `b1_int` from 7.24 G to 5.60 G and `b1b_int_bounded`
from 8.56 G to 7.90 G.

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
- Not run locally: Linux execution, `--external-as` (no mingw `as` on this
  machine's PATH) and the macOS targets. The CI gates and a macOS dispatch
  cover them.

# Branch padding in the internal assembler (JCC erratum)

On Intel Skylake-derived CPUs a jump that crosses a 32-byte boundary, or
ends exactly on one, runs slowly. This is the JCC erratum and its microcode
fix. Where the jumps of a hot loop land depends on every byte before them,
so the same loop could run 5.8 G cycles in one build and 4.2 G in the next.
`docs/I64-OVERFLOW-2026-11-21.md` measured this while costing the overflow
check. Aligning only the loop head did not help (closed PR #16).

`src/hasm.rs` now pads the way GNU as `-mbranches-within-32B-boundaries`
does, but with NOPs only:

- **What is padded.** Direct `jmp` and `jcc` (the jcc+jmp types of GNU as
  `-malign-branch`). A compare-type instruction followed by a `jcc` it can
  macro-fuse with is kept with the `jcc` as one unit (the "fused" type):
  - `test`/`and` with any `jcc`;
  - `cmp`/`add`/`sub` except with `jo`, `jno`, `js`, `jns`, `jp`, `jnp`;
  - `inc`/`dec`, which in addition do not fuse with the carry-flag jumps;
  - memory with an immediate never fuses.
- **When.** If the unit would cross a 32-byte boundary or end on one,
  NOPs are inserted before it up to the boundary.
- **What is not padded.** Indirect jumps, `call` and `ret` are left alone,
  as in GNU as's default. Nothing is inserted right after raw bytes
  (`.byte` and similar), which may be a prefix of the next instruction.
- **Where.** In `encode_all`, the one text encoder behind ELF, PE and
  Mach-O Intel output. The Mach-O ARM64 translator is not affected.
  The text section starts on a page boundary in every container, so file
  offsets and addresses agree modulo 32.

GNU as also absorbs padding by adding prefixes to earlier instructions;
this assembler does not, so its bytes differ from `as` with that option.
`HASM_BRANCH_ALIGN=0` turns padding off and restores the previous output,
byte-identical to plain `as`.

## Relaxation

An item's offset is recorded after its padding, so branch relaxation and
the encoder see the same address. A short backward jump that padding
pushes out of rel8 reach is therefore promoted to near instead of being
mis-encoded (unit test `padding_that_breaks_rel8_makes_the_jump_near`).
Padding only adds bytes, so the lower bounds of
`docs/HASM-RELAXATION-2026-11-14.md` remain lower bounds.

## Cost and effect

Native Windows 11, Xeon W-2140B (Skylake, JCC erratum), hbc's own PE
output from main 24fd8472 (overflow check with per-statement stubs).
The branch was later rebased onto 90c3e2cc, whose only `src/hasm.rs`
change adds `cvttsd2sil`; the behaviour, placement and unit-test checks
below were repeated after the rebase with the same results.
Process cycles, minimum of 7 runs; CPU time agrees on every binary.
Each loop was built in three layouts: as written, and with one or three
extra `local` declarations before the loop, which move every jump.

| loop | padding off: 3 layouts | padding on: 3 layouts |
|---|---|---|
| `s := s + i * k - 1`, 500 M | 5.78 / 5.77 / 6.18 G | 4.25 / 4.24 / 4.13 G |
| `bench/b1_int.prg`, 800 M | 6.59 / 4.62 / 5.29 G | 4.62 / 4.79 / 4.62 G |
| `bench/b1b_int_bounded.prg`, 800 M | 5.78 / 7.25 / 7.92 G | 5.93 / 5.94 / 5.93 G |
| `bench/b3_call.prg`, 200 M | 3.15 / 3.15 / 3.15 G | 3.15 / 3.15 / 3.15 G |

With padding the spread across layouts is 4 % at most; without it, up to
43 %. The padded figures match what GNU as with
`-mbranches-within-32B-boundaries` gave for the same loops (4.16, 4.65 and
5.81 G), within 3 %. In its single luckiest layout, `b1b_int_bounded` is
3 % faster unpadded.

`.text` grows by 1.7 % over the 1197 manifest programs that build for
Windows (4 737 824 to 4 819 392 bytes, PE section headers read by
`objdump`). It grows by 2.0 % over the 1209 Linux builds (6 855 062 to
6 990 679 bytes, ELF section headers parsed directly).

## Verified (native Windows 11)

- **Behaviour.** Every positive manifest program (1209; 1197 build) was
  built with padding off and on, plain and `--instrument`, and run.
  Stdout, stderr and exit status are identical.
- **Placement**, checked independently of the assembler by disassembling
  every padded executable with MinGW `objdump`. No direct jump or fused
  pair crosses or ends on a 32-byte boundary. The only hits are six string
  constants in `.text` that objdump decodes as code. Without padding every
  program has violations.
- **Off switch.** Base 24fd8472 against this change with
  `HASM_BRANCH_ALIGN=0`, over the same programs for Windows, Linux and
  Mach-O Intel: 3614 executables byte-identical (PE timestamp and checksum
  normalized), 13 that fail to build in both.
- **Unit tests.** `rustc --test`: 95 passed, six of them new
  (`hasm::branch_align_tests`).
- **`tests/hasm-relaxation/check.py`** now compares with
  `HASM_BRANCH_ALIGN=0`. It already fails on main before reaching the
  comparison: `src/hpe.rs` changed after its pinned baseline 710a3cb.

# Native ancestor metadata, 14 November 2026

Review candidate, not published. On top of the separate formatted console LF
increment, based on `7d20db39627371abd2dbab02176acc165a25d9ca`. Independent
MIT Rust/assembly measured through original PRGs and black-box executable
Harbour at pin `694428e1c12f726675b19324d62167fa77d68185`.

## Contract

ProcName/ProcLine accept zero arguments or one checked I64 expression. It is
evaluated once, including postincrement and function-call effects, and then
narrowed to signed32, as measured at both signed32 wrap boundaries and I64MAX.
Current frame is zero. Positive levels walk real native language activation
links. Null returns empty name or zero line. Negative levels return the
observed builtin contract PROCNAME or zero, not a fabricated user frame.
Wrong arity and non-I64 types still reject. This is not Harbour's general
argument coercion surface. LLVM retains its old noarg/literal-zero surface;
new dynamic/ancestor forms reject explicitly, with and without tracing.

Diagnostic record size is 48 bytes instead of 32 in function/block frames.
Existing prev/diagnostic pointer/length fields at +0/+8/+16 stay unchanged;
+24 holds the current Harbour line and +32/+40 the canonical language name.
Names are immutable borrowed strings; no heap/value ABI/ownership changes.
Leaf helpers make no calls, allocate nothing and stop at null regardless of
the requested positive depth. Byref specialization suffixes stay hidden in
the language name, INIT retains its `$` suffix, and recursion retains every
activation. Caller lines are suspended call sites; blocks keep their observed
block-definition line and `(b)` name. Normal unlink/early-return behavior is
reused. No terminal dialogue handling is introduced.

A small program-wide static proof controls line stores, not frame size. Only
known harmless AST forms and a short builtin allowlist can skip the store.
Every function is inspected, including dead arms. ProcName/ProcLine, Eval,
unknown builtins/nodes, function references and externs keep stores enabled.
The default is conservative. No arbitrary dynamic-call safety is inferred.

## Fresh evidence

Final compiler SHA256:
`c879c4cf7a779aa9c654759edd0edccf80ecbf19c1f72fb5b38066ac6323d237`.

- The unchanged original `tests/procname.prg` prints FIVE:32, FOUR:23,
  THREE:17, TWO:11 and MAIN:5, exact stdout/stderr/exit against GTSTD.
- 1041 actual upstream PRGs have verified inventory SHAs: 32 admitted, all
  under tests/268. Only procname is newly admitted. The 19 original `.hb`
  scripts accidentally renamed in inventory metadata are not PRGs or counted.
- All 30 non-dialogue admitted originals freshly match GTSTD in Linux
  instrumented runs. and_or/errsys remain blocked dialogue cases, not passes.
  dynwin checks only Linux's excluded-Windows branch, not DLL support.
- 17 positives plus 14 type/arity rejections across Linux/Wine and both modes:
  124/124. Includes the prior 60-channel smoke and signed32 wrap controls.
  Wine establishes candidate consistency, not a Windows Harbour oracle.
- Full manifest has 1692 entries. Linux instrumented:1692 passes. Linux normal:
  1691 passes plus the mode-dependent registry guard, byte-identical to base.
  Wine instrumented:1671 passes plus 21 base-identical target gaps. Wine normal:
  1670 passes plus those gaps and the normal guard. No new regression in any
  of four complete traversals. Windows class/CurDir boundaries and diagnostic
  precedence remain explicit; no all-green Windows claim is made.
- Five former ancestor/effect rejections become positives at unchanged source
  paths. Wrong arity remains rejected. No expectation is changed to hide an
  error. Existing exact diagnostic streams and pending-space matrices pass
  as part of the complete manifest.
- 16 controls cover conservative metadata classification and new LLVM
  rejections in both profiles. `tools/check_procmeta.py` reproduces all 124
  channel cases. Existing original and rejected input bytes stay unchanged.

## Performance, not a blanket speedup

All samples use the small native wait4 parent from tests/vas/measure.c, not
Python's inherited RSS high-water. Nine interleaved base/new pairs, identical
program channels, final compiler above:

| Program | Base median ms | New median ms | Delta |
| --- | ---: | ---: | ---: |
| I2 b4 million allocations | 4684.649 | 4656.984 | -0.59% |
| I2 b5 concatenation | 15.817 | 15.993 | +1.11% |
| VAS AAdd enabled | 15.569 | 16.368 | +5.13% |
| VAS ASize enabled | 8.077 | 7.937 | -1.74% |
| VAS 64 live enabled | 3.909 | 4.057 | +3.77% |
| VAS over-reservation enabled | 17.321 | 16.971 | -2.02% |

Raw min/max, all samples, RSS and runtime-off/compile-off modes are retained.
Other VAS mode deltas range from -10.48% to +9.79%; these short samples are
noisy and no improvement is claimed. The exact 42-entry ASize source cohort
has 840 base/new executions (9 normal pairs plus one instrumented pair each),
all channel-identical; per-source median deltas range -13.13% to +17.26% at
submillisecond process times and are observations, not a speed threshold.

Before the static gate, b5 regressed +23.45%; that rejected series is retained.
The gate returns b4/b5 to overlapping spreads while retaining the 48-byte
frame for all programs. The residual +1.11% b5 median is declared, not hidden.

## Known unrelated array difference

`LOCAL a := {2147483647}; ? a[1]` prints LF plus one leading space before the
number in the pinned Harbour oracle, but LF directly followed by the digits
in both base and this candidate. A minimal PRG and all three raw results are
retained in review evidence under known-array-difference. It was exposed while
labeling wide depth tests. The permanent wide test isolates metadata return
values; it does not claim this pre-existing numeric formatting issue is fixed.

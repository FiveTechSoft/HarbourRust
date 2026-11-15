# PadC, RAt, Stuff, IsDigit/IsAlpha/IsUpper/IsLower and StrZero

Base: 2582ff7. Eight string builtins, plus two PadL corrections found
while pinning PadC. Every rule below was measured against real Harbour
3.2.0 (mingw64 build, linked with the `bench/run_bench.py` recipe), not
assumed.

## Semantics

| call | Harbour result |
|---|---|
| PadC("ab", 6) / PadC("abc", 6) | `  ab  ` / ` abc  ` (left pad = floor) |
| PadC("abcdefg", 4) | `abcd` (LEFTMOST bytes) |
| PadC(x, 0), PadC(x, -2) | empty |
| PadC("", 3, "xy") | `xxx` (first fill byte) |
| PadC("ab", 5, "") | NUL fill: Harbour reads the terminator |
| RAt("an", "banana") | 4 |
| RAt("", s), RAt(longer, s) | 0 |
| Stuff("abcdef", 2, 0, "XY") | `aXYbcdef` |
| Stuff(s, 0, 1, "X") | start 0 stays 0: `Xbcdef` |
| Stuff(s, 10 or -1, 1, "X") | start out of range appends: `abcdefX` |
| Stuff(s, 3, -1, "X") | negative delete eats the rest: `abX` |
| IsDigit/IsAlpha/IsUpper/IsLower | first byte only; empty is .F. |
| IsAlpha(Chr(233)) | .F. (ASCII only) |
| StrZero(-5, 4) | `-005` |
| StrZero(12345, 3), StrZero(-5, 1) | `***`, `*` (stars untouched) |
| StrZero(5), StrZero(7, 0) | ten digits (width below 1 is absent) |

Stuff follows Harbour's unsigned `HB_SIZE` clamps: a start below 1 other
than 0, or past the end, becomes the length; a delete count below 1 other
than 0, or past the end, becomes the remaining length.

## PadL corrections

Pinning PadC exposed two PadL divergences, fixed here:

- `PadL("ab", 0)` and `PadL("ab", -3)` returned `ab`; Harbour returns the
  empty string. The empty path loaded the length into the wrong register.
- `PadL(x, n, "")` padded spaces; Harbour pads NUL bytes. A missing fill
  argument still pads spaces.

## Implementation

The checker gives each accepted arity a fixed positional kind list
(string or integer). Code generation evaluates the arguments once, left to
right, into stack slots. A borrowed string is snapshotted when a later
argument contains a call, so a by-reference callee cannot change what the
helper reads. Owned temporaries and snapshots are released after the call.
The helpers `hbc_padc`, `hbc_rat`, `hbc_stuff` and `hbc_ischar` sit next to
`hbc_padl`. StrZero reuses Str's integer field and rewrites the fresh owned
result in place with `hbc_strzero_fix`.

The new names are reserved, like earlier builtins. A program that defined
its own `PadC` or `StrZero` must now drop that definition.

## Verified

- Real Windows PE: the oracle matrix and the ownership checks in
  `tests/string-extra/strfns.prg` are byte-identical to Harbour, plain and
  `--instrument`, with `hb_memcheck()` at 0.
- Native Windows battery report (internal PE, 1737-case manifest): the
  original run summary reports 1553 PASS and 23 SKIP, then a 414-case rerun
  after an environment break, with `gen/arith.prg` checked by hand because
  its input was untracked. These are reported run counts, not reconciled
  unique-case totals: 1553 + 23 = 1576, and adding 414 would give 1990, not
  1737. The source tree does not include the per-case logs for these runs,
  so their overlap and final PASS/SKIP/failure totals cannot be verified
  here. No aggregate full-battery pass claim is made from these counts.
  The report also records a fixture CRLF mismatch from `hb_eol()`, changed
  to `Chr(10)` before its reported successful rerun.
- The same fixture compiles for the Linux ELF and Mach-O Intel targets. It
  was not executed there.

## Limits

StrZero took integers only in this unit; floats and the decimal argument
arrived with [STR-DECIMALS-2026-11-15.md](STR-DECIMALS-2026-11-15.md).
Integer arguments must be I64; Dyn cells and floats are rejected with a
named error. No codepage-aware character classes.

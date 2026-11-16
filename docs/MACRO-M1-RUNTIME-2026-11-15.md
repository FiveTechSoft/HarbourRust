# Macro operator M1, runtime evaluator: `&(expr)` and `&name`

Base: 1c08a0f, re-applied on 6f3927f (staged parse/fold/evaluate). 1c08a0f added the compile-time gate in
[MACRO-M1.md](MACRO-M1.md), which lowers closed literal text at compile
time. This increment adds the run-time half, so the two paths compose:

1. **Literal text the gate admits** is lowered at compile time, as before.
2. **Everything else in expression position** is evaluated at run time by
   an evaluator embedded in the binary. That covers dynamic text such as
   `&c` or `&(cExpr)`, and `&name`. It also covers literal text the gate
   rejects: floats, powers, names, deferred errors, lists and nested
   macros. Harbour compiles every macro text at run time, so this fallback
   never changes a program's meaning.
3. **Statement, lvalue and dynamic-send macros** stay compile-time limits.

The evaluator replaces the runtime draft in fe6b34c. That draft allocated
result strings with the DBF blob's OS allocator, while hbc releases Dyn
strings with `hbc_freestr`. It also had no float or folding semantics.

## What works

`&(expr)` and `&name` evaluate a string at run time and return a Dyn
value. The operand must be string-typed (a literal, a string local, or a
string expression). The value then flows like any Dyn: `?`, assignment,
`ValType` through a local, `Empty` and the rest. Programs without `&` are
unchanged. The evaluator is emitted only when a program uses it.

M1 covers constant expressions:

- **Literals:** integers, decimals, hex (`0x10`), strings in `"…"`, `'…'`
  and `[…]`, `.T./.F./.Y./.N.` and `NIL`.
- **Operators:** unary `-` and `+`, `^` and `**`, `* / %`, `+ -` on numbers
  and strings, comparisons (`= == != <> # < <= > >=`), `$`, and
  `.NOT./!`, `.AND.` and `.OR.`.

## Semantics (measured against Harbour 3.2.0)

Harbour's macro compiler constant-folds before running, so these are its
folding rules (expropt2.c), not its runtime operator rules:

| macro | Harbour |
|---|---|
| `10 / 2`, `7 / 7` | integer 5, 1 |
| `10 / 4`, `1.5 / 0.5` | 2.50, 3.00 (two decimals) |
| `1 / 0`, `5 % 0`, `1.5 / 0` | integer 0, no error |
| `1.5 * 2`, `1.5 * 2.25` | 3.0, 3.375 (decimals add) |
| `2 + 3.0`, `0.1 + 0.2` | 5.0, 0.3 (max decimals) |
| `-7 % 3`, `-7.5 % 2` | -1, -1.50 (dividend sign) |
| `2 ^ 10`, `2 ^ 3 ^ 2`, `-2 ^ 2` | 1024.00, 64.00, 4.00 |
| `1 .AND. .T.`, `.F. .AND. 1` | 1, .F. (folded) |
| `"abc  " - "def "` | `abcdef   ` |
| `"abc" = "ab"`, `"ab" = "abc"` | .T., .F. (SET EXACT OFF) |
| `10000000000`, `-123456789012` | literal widths 12 and 20 |

Floats carry width 10, or 20 from 1e10 upward or -1e9 downward. Integers
use hbc's literal-integer kind, so they print with literal widths.

Three more rules came out of differential fuzzing against Harbour:

- **Default decimals.** Results of `/`, `%` and `^` carry Harbour's
  default-decimals marker, not a literal 2. The marker wins in any later
  `+ - *` and prints as SET DECIMALS. So `(14 ^ 3) * 3.55` is `9741.20`,
  not `9741.2000`.
- **Run-time values.** Harbour folds only constant operands. A division
  or `%` by zero is not folded; it runs and returns the integer 0. Values
  computed from it follow the run-time rules, where `/` and `%` always give
  a default-decimals double: `5 % 0 % 1` is `0.00`, while `0 % 1` is `0`.
  `.AND.`/`.OR.` fold only against a constant logical, so
  `'ab' - hidden + 1 .OR. (1/0) <= 2.5` raises BASE/1003.
- **Grammar.** Equality (`= == != <> #`) is one precedence level below
  ordering (`< <= > >= $`). That decides which error comes first in
  `.T. != 0 - 2.5 $ 2.5` (BASE/1109). `.NOT.` and `!` may start an
  operand (`x / .NOT. y`). `++` and `--` are syntax errors, so `--5` is not
  5. A non-logical left operand of `.AND.`/`.OR.` raises
  `BASE/1066  Argument error: conditional`.

Integer powers use double-double arithmetic and are correctly rounded.
Fractional powers use the x87 `2^(y*log2 x)`. `%` uses an exact `fprem`.

Harbour folds before it resolves names or raises operand errors. Errors
are therefore deferred values: the first one in evaluation order wins, and
logical folding can discard it. `.F. .AND. hidden`, `.T. .OR. hidden` and
`hidden .AND. .F.` all fold without an error, as in Harbour. `(1, 2)` is a
list whose value is 2. A nested `&('1')` evaluates its text, while a
nested `&name` is BASE/1003. An `&name.` inside a string stays literal
text.

An error that survives prints Harbour's message on stderr and exits 1.
The stdout callstack is the same as every other hbc runtime error.

| cause | message |
|---|---|
| bad syntax, empty text, `10.`, `1e3` | `Error BASE/1449  Syntax error: &` |
| a name (LOCALs are invisible, as in Harbour) | `Error BASE/1003  Variable does not exist: X` |
| operand types | `Error BASE/1070`-`1088` and `1109`, Harbour's codes and text |

## Implementation

- `runtime/hrmacro.c` is freestanding C with no system headers. It is
  compiled ahead of time by `tests/generate_macro_asm.py` with
  `-mabi=sysv` into `generated/hrmacro.s`. SysV is hbc's internal
  convention on every target, so one assembly file serves PE and ELF.
  Developers need GCC to regenerate it; hbc users need no toolchain.
- hbc supplies the shims `hrm_alloc/free/float/exp/log`. Each preserves
  the SysV callee-saved registers around hbc's hand-written helpers.
  `hrm_fail` is per target.
- The result is an owned Dyn cell. Strings come from `hbc_stralloc`, so
  existing consumers release them with `hbc_freestr`. Floats are heap
  items from `hbc_float_new`.
- The internal assembler gained the forms GCC emits: `cltq`,
  `cvtsi2sdl/q`, `cvttsd2siq` and `movaps/movups/movapd`. A unit test
  pins each against GNU `as` bytes.

## Verified

- `tests/macro/m1-values.prg` covers 109 macro expressions with ValType,
  plus a 200-iteration owned-string loop. On real Windows PE it is
  byte-identical to Harbour, plain and `--instrument`, with
  `hb_memcheck()` at 0.
- `tests/macro/m1-syntax-err.prg`, `m1-local-invisible.prg` and
  `m1-arg-err.prg` check exit 1 and Harbour's message.
- t828 changed from a rejection to a positive case (`? &e` with
  `"1+1"` prints 2). The 1c08a0f fixtures `tests/macro-m1/*.prg` still
  pass through the compile-time path. Every other macro and
  preprocessor-macro manifest case passes too.
- `tests/macro-m1/check_oracle.py` now lists only the five forms that are
  still rejected at compile time. The removed forms now compile, and
  their run-time results are checked against Harbour by
  `tests/macro/m1-values.prg` and the error fixtures above. That gate
  needs Linux, Wine and hbmk2, and it was not re-run here.
- The Linux ELF build assembles. It was not executed, because no Linux
  runtime was available. Mach-O rejects the operator with a named error.
- **Differential fuzzing against Harbour 3.2.0 (native Windows):**
  - 40 seeds of 400 random typed expressions each (16,000 in total).
    Every remaining difference is one of the two known divergences listed
    under Limits: 2 asterisk overflows and 1 CRT `pow` ulp.
  - 240 single-expression programs mixing types, names and zero divisors.
    Exit status and Harbour's error line match in all of them.
  - A 400-case power matrix with integer, negative and fractional
    exponents. Its only differences are the same two kinds.
- **Full native Windows battery** on the final compiler: 1,744 manifest
  cases, 1,721 pass, 23 skipped (Linux-only classes), 0 fail.

## Native Windows crash in 6f3927f, and the generator

6f3927f generated `generated/hrmacro.s` with Linux GCC and
`-mcmodel=large`. That emits 64-bit absolute addresses for string
constants and callbacks (`movabs $.LC0`, `$hrm_alloc`). hbc's PE has
DYNAMIC_BASE set and no base-relocation table. Native Windows loads the
image at a randomised base, so every program using `&` or PRIVATE
crashed with a segfault, including `? &("1+1")`. Wine loads at the
preferred base, which hid it.

The generator now uses MinGW GCC with these flags:

- `-mabi=sysv` with `-D_WIN64`, so the MinGW headers detect the platform.
- `-mcmodel=small`, so every symbol is RIP-relative and no `.refptr`
  slots are needed.
- `-fno-tree-vectorize`, which keeps function pointers out of
  constant-pool vectors.
- `-mno-stack-arg-probe`, `-minline-all-stringops` and
  `-mstringop-strategy=rep_byte`, so the code needs no `___chkstk_ms`,
  `memcpy` or `memset`.

Every `rep movs`/`rep stos` form is byte-encoded. The output has no
absolute symbol references. The same assembly serves PE and ELF.

The M0 memvar path from 6f3927f was checked against Harbour with
`tests/macro/m0-memvars.prg`: current values, case folding and run-time
rules. After the shared evaluator fixes below it is byte-identical. A
memvar is a run-time value, so `x % 3` with `x := 10` is `1.00`.

## Limits

- **M0 is in.** Since 6f3927f, `&name` and names inside `&(...)` resolve
  PRIVATE/PUBLIC memvars, including those declared by a caller. Integer,
  logical, NIL, string and float values read back byte-identical to
  Harbour 3.2 (fixture `tests/macro/m0-memvars.prg`). Memvars cannot be
  assigned from macro text (that is M4).
- **No calls or assignments.** Function calls inside the text (M2),
  assignments with `:=` and array, hash or codeblock literals (M4) end
  with a named run-time error. That message is not a Harbour message.
  Neither is field access (M3), which Harbour resolves when a work area is
  open.
- **Operand types.** A Dyn operand, such as an uninitialised `local c`
  later assigned a string, is rejected at compile time. Declare it
  `local c := ""`.
- **Not supported:** `&name.` text substitution, macros inside strings,
  and `&name(...)` calls.
- **Pre-existing hbc behaviour that shows up with Dyn results:**
  - A Dyn float compared with a number fails with a misleading NIL type
    error.
  - Fixed in this unit for every program: a negative float that rounds to
    zero printed `-0.00`, and Harbour prints `0.00`. The fixture is
    `tests/print-f64/negzero.prg`.
  - `?` drops trailing spaces at the end of a line.
  - Mixing `??` with `OutStd` reorders buffered trailing spaces.
- **Powers and the C runtime.** Harbour calls the C runtime `pow`, which
  can be one ulp away from the correctly rounded result. hbc returns the
  correctly rounded value, so above about 1e15 the 16th printed digit can
  differ: `146 ^ 9` prints `...633170000.00` here and `...633160000.00` in
  Harbour.
- **Overflow past width 20.** hbc's float printer grows the field instead
  of printing Harbour's asterisks. This is pre-existing and shared by every
  float in hbc, not only macro results.

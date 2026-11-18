# Dyn * Dyn with a float operand

Scope: only `*` between two Dyn operands (the earlier known limit `a*b` with `a := 1.5`, `b := 2`). Original MIT code and tests;
Harbour 3.2.1dev r2610242111 is an external oracle only (not Harbour 4).

Behaviour: int*int stays inline (tags 0 and 9, `jo` under CHECKED_I64); any mix with a float runs the runtime helper `hbc_dyn_mulf`
(float*int in both orders, float*float; the result is a heap float with the usual decimals rule); string, NIL or logical operands raise
the same runtime error as the oracle (catchable with TRY). The marking is the same one `+` uses (`print` item, assignment to a Dyn
variable, chains `a*b*c`); no ABI or representation change.

Gate: `python3 tests/dyn-float-mul/check.py --compiler HBC --hbmk2 HBMK2 --mingw-lib DIR --output OUT`
- `pe-*`: PE under Wine, stdout byte-identical (CRLF) to the external oracle output of `float-dyn`, `mulf-values`, `mulf-errors`
  (the programs live in `tests/dyn-dyn-plus/programs/`, where `check.py` also compares the ELF output with the oracle).
- `mem-owned-N` and `mem-try-N` (N = 1, 500, 1000; ELF internal, ELF external, PE): owned and chained temporaries
  (`a*b`, `a*b*c`, `(a*b)*c`, `b*c`) and the error path under TRY (`a*s`, float times string); pending 0 and hits == N on the TRY rows.

Not covered (measured, left as before): `a*2` (Dyn times a literal integer) and `a*(b/z)` (Dyn times a float-typed expression) stay on
the older path and keep their named limit error; `+` and `-` with a float Dyn; dates; string subtraction; integer overflow into float.

Right-operand throw (rows `rhs-*-N`, N = 1, 500, 1000; ELF internal, ELF external, PE): the left operand is a borrowed float variable (`a*F(b)`), an
owned float temporary (`(a*b)*F(b)`, `a*b*c*F(b)`) or the right side is itself an owned temporary (`a*(b*F(b))`), where `F` is a user function that
returns a Dyn value and does `Break` under TRY. Output (hits, the untouched left variable, the target still NIL, the number of times the callee
was entered) is byte-identical to the external oracle and `hb_memcheck` pending is 0. `rhs-control-no-throw-N` runs the same shape with a callee
that returns normally. `--rows rhs` runs only these rows. Mutants of the compiler (no release of the left snapshot on the landing pad; no clone of a
borrowed float left) fail these rows; their logs are in the review package.

Limits found while writing the rows (measured, not changed here, and not covered by a passing row):
- Alias mutation of the left operand by the right one: a float left cannot be mutated by the right operand in this subset (a float inline `:=` and float
  array elements are named rejections), so there is no reachable shape to assert. `r := a*(b := 3)` and `r := a + (b := 3)` with `a := 1.5` raise
  "NIL used as a number" at run time where the oracle prints 4.5 (also with `b` unrelated to `a`); `a*Ok(2)` (a call typed as an integer) raises the same error.
- `catch e` with `Break("text")` repeated in a loop leaks N-1 cells (`catch` without a variable does not), on the previous compiler too; the rows use `catch`.

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
A throw while evaluating the right operand is not covered by a dedicated row here.

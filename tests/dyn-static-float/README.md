# dyn-static-float

A static float operand (a float literal or a float-typed call) next to a Dyn, for `+`, `-` and `*`. Measured on the compiler before this
change (e487f68f build, sha dc8f843e): `a + 2.5`, `2.5 + a`, `a - 0.25`, `0.25 - a`, `a * 2.5`, `2.5 * a`, `a + Fl()`, `Fl() - a`,
`a * 2.5 + c` ended in the named rejection "arithmetic between a NIL-able (Dyn) value and a float is a covered LIMIT of this increment";
`a + b + 2.5` and `-a + 2.5` compiled and raised "NIL used as a number" at run time (the Dyn sub-expression lost its Dyn route under the float
parent). The oracle prints 4.0, 4.0, 1.25, -1.25, 3.75, 3.75, 4.0, 1.0, 4.00, 6.0, 1.0 (Dyn `a := 1.5`, `c := 0.25`, `b := 2`).

Now, at a Dyn consumer (print item, assignment to a Dyn slot, chains of `+ - *`), a static float operand enters the Dyn route of
dyn-mul-i64 / dyn-addsub as an owned heap float with its static dec and width (the same pair `cg_data_value` builds for a float stored in a
Dyn slot). The result is the Dyn float: dec = max for `+ -`, sum for `*`. Only the operand classification and the operand snapshot changed
(`mul_mixed_tys`, `cg_mul_snapshot`); the helpers `hbc_dyn_mulf/addf/subf` are unchanged.

Run: `python3 check.py --compiler HBC --hbmk2 HBMK2 --output DIR` (fresh DIR): PASS/FAIL per row, `passed/total`, exit 1 on a FAIL.

- `prog-values`: stdout byte-identical to the oracle on ELF internal, ELF external and PE (Wine, CRLF): literals and float-typed calls
  on either side, dec rules, big values, chains, unary minus, assignment, loop, a float-typed callee that throws on the right, on the left and
  inside a chain under TRY, and string operand errors (an error in both).
- `mem-<kind>-<N>` (14 kinds x N = 1, 500, 1000, three targets): `hb_memcheck` pending 0 on the second round, `a` unchanged, hit and callee
  entry counters equal N where the callee throws. Float-typed and integer-typed throwers, on either side, in chains and after pending print items.

Controls (logs in the package): the previous compiler (e487f68f build) 0/46; a mutant that clones the owned static-float snapshot (the
original leaks) 10/46; both exit 1 as expected.

Not covered:
- Numeric contexts that are not a Dyn consumer keep their previous behaviour: `IF a + 2.5 > 2` is still the named rejection, `IF a + 1 > 2`
  still raises "NIL used as a number" at run time (measured; the oracle runs both).
- `-` between two Dyn strings (Harbour concatenates with trimming: `"x " - "y"` gives `"xy"`): the Dyn route raises a type error, as the previous
  compiler did. Left as a documented difference, no change in this cut.
- `/` with a float Dyn.

Original MIT; Harbour 3.2.1dev r2610242111 is only an external oracle (not Harbour 4).

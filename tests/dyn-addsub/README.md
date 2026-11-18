# dyn-addsub

With a Dyn `a` holding a float (`a := 1.5`, `b := Ok(2)` style), the external oracle prints `a+1` 2.5, `1+a` 2.5, `a-1` 0.5, `1-a` -0.5,
`a-b` -0.5, `-a` -1.5, `a+(b:=3)` 4.5, `a+a` 3.0, `a+b` 3.5. The compiler before this change (v3, 296c9eee, sha dcc21a66) measured:
`a+1`, `1+a`, `a-1`, `1-a`, `a-b`, `a+b+1`, `a+(b:=3)`, `-a` ended in the run-time "NIL used as a number" type error, and `a+b`, `a+a`
(Dyn+Dyn floats) in "Argument error: +".

Now, at a Dyn consumer (print item, assignment to a Dyn slot, and chains of `+ - *` below those):
- `+` and `-` with one Dyn and one static integer operand take the Dyn route used by `*` (the integer enters as an integer cell);
  `-` between two Dyn takes it too; a float on either side is added or subtracted as doubles, dec = max of the operands' dec, into an
  owned heap float (runtime helpers `hbc_dyn_addf`/`hbc_dyn_subf`, same entry contract as `hbc_dyn_mulf`, which they share a body with).
- Dyn+Dyn `+` keeps its string concatenation and integer add; a float payload is now kept in the operand snapshot (owned clone of a
  borrowed one) and added by `hbc_dyn_addf`. Any other kind is a type error after BOTH operands evaluated, as before.
- `-a` (parsed as `0 - a`) works through the same route.
- Integer-valued Dyn operands give the same integer result and type as before (overflow checks unchanged).
- The PRINT landing pad of dyn-mul-i64 releases the pairs of these items when a later item throws.

Run: `python3 check.py --compiler HBC --hbmk2 HBMK2 --output DIR` (fresh DIR): PASS/FAIL per row, `passed/total`, exit 1 on a FAIL.

- `prog-values`: stdout byte-identical to the oracle on ELF internal, ELF external and PE (Wine, CRLF): literals, calls, assignment
  expressions on either side, chains, integer Dyn, big integers, unary minus, loop, throws on the right and on the left under TRY, and
  float/string and integer/string errors (an error in both).
- `mem-<kind>-<N>` (16 kinds x N = 1, 500, 1000, three targets): `hb_memcheck` pending 0 on the second round, `a` unchanged, hit and
  callee entry counters equal N where the callee is meant to throw (so the caught error is the callee's Break).

Controls (logs in the package): the previous compiler (v3 build) 21/49, a mutant whose Dyn op route does not release its operand
snapshots on success 19/49, both exit 1 as expected.

Not covered (named rejection or previous behaviour, left as is):
- a STATIC float operand or a float-typed call result next to a Dyn (`a + 2.5`, `a - Ok(2)` when `Ok` is float-typed) keeps the named
  rejection "arithmetic between a NIL-able (Dyn) value and a float is a covered LIMIT" (the same rejection `*` has).
- `-` between two strings (Harbour concatenates with trimming, "x " - "y" gives "xy"): the Dyn route raises a type error, as the previous
  compiler did; not changed here.
- Numeric contexts that are not a Dyn consumer (an `IF a + 1 > 2` condition) keep the integer route and still raise for a float Dyn.
- `/` with a float Dyn.

Original MIT; Harbour 3.2.1dev r2610242111 is only an external oracle (not Harbour 4).

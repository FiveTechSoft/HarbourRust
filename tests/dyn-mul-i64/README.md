# dyn-mul-i64

`a * 2`, `2 * a`, `a * Two()`, `a * (b := 3)` with a Dyn `a` holding a float (`a := 1.5`) ended in "NIL used as a number" at run time
(measured on the previous compiler; the external oracle prints 3.0 / 3.0 / 3.0 / 4.5). Dyn*Dyn already multiplied floats; Dyn*integer went
through the integer extraction. Now, at a Dyn consumer (print item, assignment to a Dyn slot, and `*` chains below those), a `*` with
one Dyn and one static integer operand takes the Dyn*Dyn route, the integer entering as an integer cell. Integer-valued Dyn operands
give the same integer result and type as before.

Run: `python3 check.py --compiler HBC --hbmk2 HBMK2 --output DIR` (fresh DIR): PASS/FAIL per row, `passed/total`, exit 1 on a FAIL.

- `prog-values`, `prog-print`: stdout byte-identical to the oracle on ELF internal, ELF external and PE (Wine, CRLF): literal/call/assignment-expression
  operands on either side, chains, integer Dyn, loop, an integer-typed call that throws on the right and on the left under TRY, and
  string operands (error in both).
- `ctl-*` (3): accepted print shapes, stdout identical to the oracle on the three targets.
- `mem-<kind>-<N>`: N = 1, 500, 1000 on the three targets; `hb_memcheck` pending 0 on the second round, `a` unchanged, hit and callee
  entry counters equal N (so the caught error is the callee's Break). Kinds: owned float temporaries, right/left/chain throw, and print statements that throw after a pending Dyn*integer product, Dyn*Dyn product, two products, a concat error, an arithmetic type error (two forms), an owned call result, a cloned Dyn float, a cloned Dyn string, an owned string temporary.

Pending output pairs on a throw. A `?` statement evaluates ALL its items first and keeps one {tag, payload} pair per item on the stack until
the render. A throw in a LATER item unwound past the owned pairs and leaked them (measured on the previous compiler, N=500, second round, under
TRY: `? a*b, Boom()` 500 (Dyn*Dyn, already published), `? a*2, Boom()` 500, `? a*2, c*4, Boom()` 1000, `? a*2, b + "x"` 500, `? a*2, b - 1`
and `b + 1` with `b := "x"` 500, `? Own(), Boom()` 500, a cloned Dyn float or string item before a throw 500). The output evaluation now registers
a landing pad when the statement has 2+ items and a non-last item holds an owned pair (Dyn pair: float cell or tag-4 string, released exactly like
the render does; owned string temporary: a call or an operation with a string result). The pad releases the pairs already materialized (a count slot
updated before each item says how many) and keeps unwinding the same error. Evaluation order, output text and the success path are unchanged
(`prog-print`, `inta.prg` in dyn-dyn-plus).
Not covered: pairs of other kinds in the same statement (a borrowed array element, an iif raw cell, a float STATIC) keep the previous behaviour.

Not covered: `/` with a float Dyn. `+` and `-` with a float Dyn are covered by tests/dyn-addsub. Numeric contexts that are not a Dyn consumer
(an `IF a * 2 > 1` condition) keep the integer route and still raise for a float Dyn.

Control rows (see the gate logs): the previous compiler (a00a92ce build), the e519f136 build (v2, named rejection, 19/53) and a mutant whose landing pad releases nothing all fail the gate.

Original MIT; Harbour 3.2.1dev r2610242111 is only an external oracle (not Harbour 4).

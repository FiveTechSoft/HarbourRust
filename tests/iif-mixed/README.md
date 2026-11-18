# iif() with branches of different scalar types

Contribuido por Julio Ponce, licencia MIT. Original MIT code and tests; Harbour 3.2.1dev r2610242111 is an external oracle only (not Harbour 4).

Scope: `iif(cond, a, b)` where the two branches are scalars of DIFFERENT types: string, integer, logical, float, or one scalar and a
literal `NIL` (an omitted branch counts as `NIL`). The taken branch keeps its own type; the result is a fresh owned Dyn cell and only the
taken branch is evaluated. Borrowed strings and owned temporaries are copied (owned temporaries are then released); an owned-string
variable keeps the existing rule of an `iif` arm: it moves its buffer when that arm is taken.

Combinations with their own earlier route are unchanged: same scalar type, integer with float, two strings, two NIL arms.

Placement (fail closed): a mixed `iif` result is an OWNED tagged cell. It is accepted only directly as the LAST (or only) argument of `?`/QOut-style output,
as the right side of an assignment to a dynamic variable or a `local` initializer, and as a `return` value. Everywhere else it is a named
compile error ("a mixed-type `iif` result (an owned tagged value) is only supported directly in ..."). Reason (probes run before the fix on the
previous version, 50 rounds under TRY): `hb_ntos(iif(.T.,"x",1))`, `hb_ntos(iif(.T.,1.5,"x"))`, a call argument to an integer parameter,
assignment to an integer slot, `iif(..) - 1`, `iif(..) + 1` and `IF iif(..) < 2` each left 50 pending allocations once the consumer raised
an error; `Left("abc", iif(..))` leaked even without an error. The consumers borrow the cell and do not release it.
Rows `reject-*` (manifest t1694..t1702 repeat them) compare with the previous compiler: it accepts all nine, this one refuses them.
`ctl-N` runs the same consumers with a non-mixed `iif` (int branches) under TRY with a Break every other round: hits N/2, pending 0.
Index `a[iif(..)]` and `Chr`/`Abs`/`Space` were already refused before this change.

Documented limit (not changed here): `IF x` where `x` holds a string cell ends the process with "Type error: condition is not a logical";
it is not catchable by TRY (row `limit-if-condition`, file `failure-mode-if-condition.prg.txt`: rc 1, `recovered` not printed). The oracle also
reports a runtime error there.

Combinations with their own earlier route are unchanged: same scalar type, integer with float, two strings, two NIL arms. Object, array, block
and date arms, Dyn variables, Dyn call results, nested mixed `iif` and raw array cells keep their named rejections (t1687..t1693, t1495..t1497).

Manifest: t989 and t1002 were negative rows protecting this limit; they are now positive rows with the oracle output (executable rows 1258 -> 1260).

Gate: `python3 tests/iif-mixed/check.py --compiler HBC --hbmk2 HBMK2 --output OUT`
- `prog-*`: ELF (internal and `--external-as`) and PE under Wine, stdout byte-identical to the external oracle (PE with CRLF).
- `mem-N` (N = 1, 500, 1000; ELF internal, ELF external, PE): owned temporaries, string copies, floats, NIL and a `Break` inside a taken arm
  under TRY, only in the accepted positions; `hb_memcheck` pending 0 and hits == N/2.

Not covered: Linux/PE only (Mach-O is only compiled by the manifest emission check). `ValType(iif(...))` and every other direct use of the mixed result are rejected (see Placement). Earlier output items are evaluated before the render, so a Break in a later item would lose the pending cell: a mixed `iif` followed by another item is rejected (rows `reject-m1..m3`, measured before the change: hits N, pending N for N=1/500).

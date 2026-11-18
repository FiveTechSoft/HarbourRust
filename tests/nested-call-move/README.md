# Nested calls that consume an owned string variable

Original MIT code and tests; Harbour 3.2.1dev r2610242111 is an external oracle only (not Harbour 4).

Defect fixed: `F(G(s), d)` (and `F(1, G(s))`, `H(G(s))`, `F(G(G(s)), 1)`, `F(G(s) + "y", 1)`, `r := F(G(s), 1)`), where `G` takes an owned string
variable `s`, was rejected with "use of moved value `s`" although `s` is read once. The cause was the argument-evidence pass of a user call:
it typed the argument expression once for evidence (which applies the move of `s`) and the real check typed it again. The evidence pass now types
a copy of the environment and restores it, so it leaves no moves behind. The check itself, move marking and code generation are unchanged.

Still rejected (negative rows t1706..t1709): `F(G(s), s)`, reading `s` after the call that moved it, moving `s` twice, and a loop that moves `s`
without reassigning it before `next`.

Gate: `python3 tests/nested-call-move/check.py --compiler HBC --hbmk2 HBMK2 --output OUT`
- `prog-values`: ELF (internal and `--external-as`) and PE under Wine, stdout byte-identical to the external oracle.
- `mem-N` (N = 1, 500, 1000; ELF internal, ELF external, PE): nested consumers with the variable reassigned each round; hb_memcheck pending 0.

Row t961 (`take((take(s),1))`) changed its expected diagnostic from "use of moved value" to "must be a string": the program is still rejected,
but the outer `take` receives an integer (`Asc(1)`), which is the real error. The same shape with an outer function that takes a number,
`Plus1((Asc(G(s)),1))`, is valid Harbour (oracle prints 2) and is now a positive line of `programs/values.prg`; the previous compiler rejected it as a use after move.

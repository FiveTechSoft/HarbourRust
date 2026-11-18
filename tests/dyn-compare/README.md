# dyn-compare

Comparisons `< <= > >= == != =` where at least one operand is a Dyn (the other a Dyn, an integer or a static float), in IF/WHILE
conditions, assignments to a Dyn slot and print items, including `+ - *` children (`IF a + 1 > 2`).

Measured on the compiler before this change (9e150aee build): `IF a+1>2`, `IF a>1`, `a<b`, `a<2`, `a>b` raised "NIL used as a number" at run time;
`a>=1.5` and `a<2.5` ended in the named LIMIT "comparing a NIL-able (Dyn) value with a float"; `a==1.5` was rejected by the `==` rule. The oracle runs all of them.

Now the three Dyn compare helpers (`hbc_dyn_eq`, `hbc_dynxcmp`, `hbc_dynxeq_dd`, in both the Linux and Windows blobs) have a float arm
(integer, heap float and legacy inline float cells compare as doubles); ordering with exactly one Dyn side goes through `hbc_dynxcmp_n`, which keeps
"NIL used as a number" for non-numbers. The checker no longer raises the LIMIT for Dyn x float. The arithmetic children of a comparison keep their
Dyn marks. The boxed operand slots now have a landing pad under an active TRY: the first owned operand is released when the second operand or the
comparison raises.

Run: `python3 check.py --compiler HBC --hbmk2 HBMK2 --output DIR` (fresh DIR): PASS/FAIL per row, `passed/total`, exit 1 on a FAIL.

- `prog-values`: stdout byte-identical to the oracle on ELF internal, ELF external and PE (Wine, CRLF).
- `mem-<kind>-<N>` (12 kinds x N = 1, 500, 1000, three targets): `hb_memcheck` pending 0 on the second round, `a` unchanged, hit and callee entry counters.

Not covered (unchanged behaviour):
- Dyn float against a non-number (measured 2026-11-18 against the oracle, C1 compiler vs the 9e150aee build, `/tmp/hr/probes-c1b`): the oracle raises a type error (BASE/1070-1076 "Argument error", dialog, no stdout) for every operator in both directions with a logical, a string, a date or an array; with NIL it answers `.F.` for `=`/`==` and `.T.` for `!=`, and raises for ordering.
  Before this change `=` and `!=` of a float Dyn with a logical or a string answered `.F.`/`.T.` (diverged from the oracle); now they stop with the named error `Argument error: =` (also printed for `!=`; the oracle names `<>`), like `==` and the ordering operators already did. Both ends are registered failure modes (the oracle's dialog hangs headless), not stdout equivalence. Dyn float against NIL: `=`, `==`, `!=` match the oracle; ordering ends in "NIL used as a number" (unchanged; the oracle says Argument error). Dates cannot be held in a Dyn slot by this compiler (compile-time rejection). A string ordering error with a float is not catchable (same as before).
- A comparison as a function argument or in `iif(...)` condition is not a Dyn consumer: `iif( a + 1 > 2, ...)` still raises "NIL used as a number".
- Numeric builtin arguments with a Dyn float and `%` are separate cuts.

Original MIT; Harbour 3.2.1dev r2610242111 is only an external oracle (not Harbour 4).

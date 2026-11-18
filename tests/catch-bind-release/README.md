# catch-bind-release

`CATCH e` stored the exception in the variable's slot without releasing what the slot still held. Inside a loop that
leaked one cell per round after the first (N-1 pending for string, Dyn float, Dyn string and Dyn array values; 2N-2 for
an array of two cells). The catch store now goes through `cg_dyn_free_old`, the helper every other store into a Dyn slot uses.

Run: `python3 check.py --compiler HBC --hbmk2 HBMK2 --output DIR` (fresh DIR). It prints PASS/FAIL per row, `passed/total`,
and exits 1 on any FAIL. `results.json` carries the compiler sha256.

- `prog-values`: stdout byte-identical to the external oracle on ELF internal, ELF external and PE (Wine, CRLF).
- `mem-<kind>-<N>`: N = 1, 500, 1000 on the three targets; hits and `hb_memcheck` pending 0 on the second of two runs.
  Kinds: string literal, owned string, string-returning call, Dyn float, Dyn array, Dyn string, integer, NIL, catch variable
  preset before the TRY, reassigned by the user inside CATCH (string, Dyn float), nested TRY reusing the same variable.

Limits (measured, not changed here): `Break()` still rejects float expressions, array literals/function results, booleans and
objects with a named error, so those kinds cannot be thrown. With N = 1 a single-catch row cannot leak (N-1 = 0); the
control compiler fails the N = 500 / 1000 rows and the preset and nested rows at N = 1.

Original MIT; Harbour 3.2.1dev r2610242111 is only an external oracle (not Harbour 4).

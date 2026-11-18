# catch-memvar

`CATCH e` where `e` is a PRIVATE/PUBLIC (MEMVAR) name compiled, but the catch store went to a frame offset a memvar never has
(offset 0), and the program ended with SIGSEGV when the exception was caught. The MEMVAR resolver is not implemented for the
catch variable, so the compiler now refuses it at the CATCH line: "CATCH variable `e` is a PRIVATE/PUBLIC (MEMVAR) binding;
the catch variable must be a LOCAL in this increment". The check is per function: a PRIVATE named `e` in another function does
not matter, and a PRIVATE declared after the CATCH is not a binding at that point (measured: it still works).

Run: `python3 check.py --compiler HBC --hbmk2 HBMK2 --output DIR` (fresh DIR). PASS/FAIL per row, `passed/total`, exit 1 on a FAIL.

- `reject-*` (5): the external oracle accepts the program and prints the thrown value; the compiler (ELF and PE targets) exits
  non-zero with the named diagnostic, empty stdout and no output file. Shapes: PRIVATE e, PUBLIC e, `PRIVATE a, e`,
  `PRIVATE e := ...`, PRIVATE inside a loop.
- `ctl-*` (3): valid shapes build and stdout is byte-identical to the oracle on ELF internal, ELF external and PE (Wine, CRLF).

Original MIT; Harbour 3.2.1dev r2610242111 is only an external oracle (not Harbour 4).

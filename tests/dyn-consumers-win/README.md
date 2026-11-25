# Dyn string consumers on native Windows

Val, CToD, Upper, Lower and AllTrim of an untyped LOCAL holding a string,
and the bare Date local that a CToD store narrows, were admitted on
ordinary Linux only. The same code generation now runs on ordinary
Windows too (no threads, no macros); Mach-O and LLVM keep the named
rejection.

Black-box evidence: Harbour 3.2 (mingw64, GTCGI, native Windows 11,
November 25, 2026); no Harbour source was read. `expected.json` holds the
stdout Harbour printed for 17 existing pins (tests/val-dyn,
tests/ctod-dyn, tests/dyn-string-unary/cases.json); hbc prints the same
bytes. `check.py --compiler hbc.exe` repeats the comparison and runs in
the native Windows CI.

Not covered here, and registered:

- cases that go through hb_defaultValue or scalar default setters still
  need ordinary Linux;
- a string holding a NUL byte: hbc's Windows console prints `.` where
  Harbour writes the byte (also true of plain string literals);
- tests/val-dyn/neg_nonstring.prg: Harbour 3.2 ends the program with
  `Error BASE/1098 Argument error: VAL` inside BEGIN SEQUENCE without an
  error block; hbc recovers (same on Linux);
- tests/ctod-dyn/neg_masked_error.prg: hbc rejects `CToD(5)` at compile
  time; Harbour raises the error at run time (same on Linux).

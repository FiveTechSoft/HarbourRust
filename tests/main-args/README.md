# Command-line arguments to main

Black-box behaviour of real Harbour 3.2 (mingw64, `-gtcgi`, native
Windows 11, November 24, 2026); no Harbour source was read.

main's parameters receive the command-line arguments as strings, in
order; a parameter past the last argument is NIL (tests/main-params pins
the run without arguments). Arguments beyond the declared parameters are
not visible through them.

Windows command-line splitting, measured with raw command lines (the
cases in `cases.json`, all byte-exact against Harbour):

- blanks and tabs separate arguments outside double quotes; runs of them
  count once, leading and trailing ones are ignored;
- a double quote toggles quoting and is dropped: `a"b"c` is `abc`,
  `"a""b"` is `ab`, `""` alone is an empty argument, an unclosed quote
  runs to the end;
- backslashes are ordinary characters (`a\"b` is `a\b`): Harbour does not
  apply the Microsoft C runtime escaping rules;
- no wildcard expansion (`*.prg` stays `*.prg`).

hbc reads `GetCommandLineA` and splits it by these rules; on Linux it
copies `argv` as the kernel delivers it. `check.py` runs `main_args.prg`
with every case (the native CI runs it on Linux and Windows).

`PCount()` in main is the number of arguments, including empty ones and
those past the declared parameters (`main_args.prg` prints it first; the
seven-argument case gives 7). Measured on Windows; on Linux hbc gives
`argc - 1`, inferred from the Windows result, not measured against a
Linux Harbour.

Registered differences:

- non-ASCII bytes: Harbour delivers them in the OEM code page (`ñ` arrives
  as byte 0xA4); hbc passes the ANSI bytes of `GetCommandLineA`;
- Mach-O and LLVM targets do not deliver arguments yet: main's parameters
  stay NIL there;
- Mach-O and LLVM: `PCount()` in main is rejected with the rest of
  PCount there.

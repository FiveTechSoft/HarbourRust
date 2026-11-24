# main's parameters

Black-box behaviour of real Harbour 3.2 (mingw64, `-gtcgi`, native
Windows 11, November 24, 2026); no Harbour source was read.

- main's parameters receive the command-line arguments as strings
  (`prog 5` gives `"5"`, `""` gives an empty string); a parameter with no
  argument is NIL. `PCount()` in main is the number of arguments supplied,
  even beyond the declared parameters.
- Run without arguments, every parameter is NIL (`main_params_nil.prg`)
  and can be assigned any value afterwards (`main_params_assign.prg`).

Each parameter of main is a local initialized from the command line
(tests/main-args): NIL when the run has no argument for it. Mach-O and
LLVM targets do not deliver arguments yet, so there the parameters always
start NIL. Programs that call main themselves keep main's parameters as
ordinary parameters.

`expected/*.windows.out` are the Harbour outputs; the `.linux.out` files
have the same bytes with LF line ends.

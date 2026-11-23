# QUIT, CLS and ALTD()

Black-box behaviour of real Harbour 3.2 (mingw64, `-gtcgi`, native
Windows 11, November 23, 2026); no Harbour source was read.

- `QUIT` ends the program from any call depth with exit code 0. Output
  already written stays; nothing after `QUIT` runs. hbc returns into
  `_start` right after the call to Main, so the normal exit path (output
  flush, DBF close, cleanup) runs. Outside this increment, each a compile
  error: `QUIT` in a program that uses threads, and `QUIT` inside an INIT
  procedure.
- `CLS` writes no bytes when output is redirected (measured under GTCGI
  and GTSTD). hbc's console is a stream, so `CLS` writes nothing.
  Registered difference: an interactive Harbour console clears the screen.
- `ALTD()` with no debugger linked does nothing.

`expected/*.windows.out` are the Harbour outputs; the `.linux.out` files
have the same bytes with LF line ends.

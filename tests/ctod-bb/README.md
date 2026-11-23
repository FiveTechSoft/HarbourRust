# CToD under SET DATE and SET EPOCH

Black-box behaviour of real Harbour 3.2 (mingw64, `-gtcgi`, native
Windows 11, November 23, 2026); no Harbour source was read.

- `CToD` splits its text into up to three digit runs (any non-digit
  separates) and reads them in the active SET DATE layout's order:
  AMERICAN and USA month-day-year; BRITISH, FRENCH, GERMAN and ITALIAN
  day-month-year; ANSI and JAPANESE year-month-day. The separator
  characters themselves do not matter (`19-05-1991` parses under
  BRITISH).
- `SET EPOCH TO <year>` (default 1900): a year whose value is below 100,
  including `0049`, becomes the first year at or after the epoch that
  ends in those two digits. A year of 100 or more, such as `149`, is
  kept as written.

`programs/ctod_order_epoch.prg` covers every SET DATE word with 17
inputs, then six epochs with 13 years each. `expected/*.windows.out` is
the Harbour output; the `.linux.out` file has the same bytes with LF
line ends. Only `SET EPOCH TO <integer>` is accepted; `Set(_SET_EPOCH)`
is not in this increment.

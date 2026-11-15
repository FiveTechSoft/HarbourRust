# Str and StrZero with decimals, and a Val rewrite

Base: ce3f9c7. Str and StrZero now accept a float value and an explicit
decimal argument. Val was rewritten after a wrong-value bug: on the base,
`Val("250")` returned 25 and `Val("1000.5")` returned 100.5. Every rule
below was measured against real Harbour 3.2.0.

## Str sizing (Harbour hb_itemStr)

Start from the value's own width W and decimals D. Then:

- A width argument sets W to it, or to 10 when it is below 1, and resets D
  to 0.
- A decimal argument of 0 or less sets D to 0. A positive one sets D, and
  when a width was given, W shrinks by D + 1.
- The field is S = W + 1 + D bytes when D > 0, otherwise W bytes.

The digits are the `?` digits: 16 significant digits, rounded half away
from zero at the last decimal. A value that rounds to zero loses its sign,
so Str(-0.4, 5) is `    0`. A result that does not fit is S asterisks.

| call | Harbour |
|---|---|
| Str(3.14159, 8, 2) | `    3.14` |
| Str(3.7, 5) / Str(2.5, 5) | `    4` / `    3` |
| Str(1234.5, 5, 1) | `*****` |
| Str(5, 3, 2) / Str(5, 4, 2) | `***` / `5.00` |
| Str(3.14159, 0, 2) | `      3.14` (width 10) |
| Str(-999.996, 7, 2) | `*******` |
| StrZero(-3.5, 7, 1) | `-0003.5` |

Integer Str without a decimal argument keeps the exact integer field.

## Val

The value follows Harbour hb_str2number. Leading whitespace is skipped,
then an optional sign is read. Digits and one dot follow, and the parse
stops at any other byte, so `1e3` is 1 and `0x1F` is 0. Digits accumulate
exactly in an integer until the next step could overflow, then in a
double. The fraction divides by 10^n at the end.

The metadata was measured, since Harbour derives it from the text:

- The decimal count is every byte after the first dot anywhere in the
  text, digits or not. `Val("12.3abc")` has 4 decimals.
- The width is the dot position when there are decimals, otherwise the
  text length. It grows to fit the integer digits and sign the value needs.
  It becomes 20 once the value is at least 1e10 or at most -1e9.
- Empty text has width 10.

## Verified

- `tests/str-decimals/strfmt.prg` holds the Str/StrZero matrix, the Val
  width matrix and an allocation loop. On real Windows PE it is
  byte-identical to Harbour, plain and `--instrument`, with
  `hb_memcheck()` at 0.
- Full native Windows battery: NOT completed. The run was stopped by the
  host for low memory after 192 PASS and one case cut off mid-run (t191,
  passes when run alone). The manifest cases that call Str, Val, StrZero,
  PadL or PadC were run separately and pass after the three updates below.
- Manifest changes: t1399 `Str(4.5)` moved from a rejection to a positive
  case with the oracle output. The t1400 and t1404 rejection texts follow
  the new messages.

## Limits

- Val results are floats. Harbour keeps an exact integer for long digit
  strings, so `Val("1234567890123456789")` prints 1234567890123457000
  here.
- Mixed numeric locals (NumLocal) and Dyn cells are not accepted as the
  Str value.
- The float formatter keeps the measured frontier of the `?` printer.
  Fields wider than its scratch buffer stop with the range error.

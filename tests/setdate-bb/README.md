# SET DATE / SET CENTURY - the runtime date render state

`SET DATE [TO] <format>` and `SET CENTURY ON|OFF` drive the runtime
date-render state (runtime/hrdate.c, generated/hrdate.s via
tests/generate_date_asm.py; clean-room, black-box fitted from native
Windows Harbour 3.2 - no GPL source read):

- AMERICAN MM/DD/YY, ANSI YYYY.MM.DD, BRITISH/FRENCH DD/MM/YY,
  GERMAN DD.MM.YY, ITALIAN DD-MM-YY, USA MM-DD-YY, JAPANESE YYYY/MM/DD.
- `SET CENTURY ON` widens the year to four digits; OFF keeps two.
  The fields are always zero-padded; the empty date renders as spaces
  (8, or 10 with century on).
- `DToS` never changes (always YYYYMMDD). The `? Date()` display and
  `DToC` share the same state; the STATE also reaches
  `Transform(date, ...)` through `hbc_dtoc` - the
  `setdate_transform.prg` pin proves the two systems agree (the earlier
  asm-side attempt had a first-call corruption; the C state eliminated
  it).

Named rejections: `SET CENTURY TO <year> ROLLOVER`, unknown format
words (SPANISH is not a Harbour format word, measured E0030).

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2
-comp=mingw64 -gtcgi, native Windows 11); the Linux files are the same
bytes with LF line ends. hbc output is byte-identical over both
programs (18 pins).

Setter-only regression: `python tests/setdate-bb/check.py --compiler ./hbc`
checks SET CENTURY ON/OFF and SET DATE without a later date-render call.
The blob must be included for those entry points too. Their empty outputs
are regression expectations, not new Harbour measurements. Linux checks
normal/instrumented and external-as paths; Windows execution is unverified.

The two original oracle programs above contain `Date()` and their pins
record November 23, 2026. They are not registered as timeless manifest
expectations. The Transform program is also outside the current Mach-O
contract, so it must not be silently added to the Mac battery.

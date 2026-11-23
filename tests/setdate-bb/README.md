# SET DATE / SET CENTURY - the runtime date render state

`SET DATE [TO] <format>` and `SET CENTURY ON|OFF` drive the runtime
date-render state (runtime/hrdate.c, generated/hrdate.s via
tests/generate_date_asm.py; clean-room, black-box fitted from native
Windows Harbour 3.2 - no GPL source read):

- AMERICAN MM/DD/YY, ANSI YYYY.MM.DD, BRITISH/FRENCH DD/MM/YY,
  GERMAN DD.MM.YY, ITALIAN DD-MM-YY, USA MM-DD-YY, JAPANESE YYYY/MM/DD.
- `SET CENTURY ON` widens the year to four digits; OFF keeps two.
  The fields are always zero-padded; the empty date keeps the layout
  and blanks every digit position ("  /  /  ", "    .  .  " with
  century on). DToS of the empty date is 8 spaces.
- `DToS` never changes (always YYYYMMDD). The `? Date()` display and
  `DToC` share the same state; the STATE also reaches
  `Transform(date, ...)` through `hbc_dtoc` - the
  `setdate_transform.prg` pin proves the two systems agree (the earlier
  asm-side attempt had a first-call corruption; the C state eliminated
  it).

Named rejections: `SET CENTURY TO <year> ROLLOVER`, unknown format
words (SPANISH is not a Harbour format word, measured E0030).

`expected/setdate_matrix.windows.out` and
`expected/setdate_transform.windows.out` are the original recorded Harbour
3.2 outputs (hbmk2 -comp=mingw64 -gtcgi, native Windows 11); their Linux
counterparts have the same bytes with LF line ends. The two original
programs matched those dated pins in local Linux checks on November 23,
2026. This provenance does not apply to the empty setter-only regression
outputs added later; those are not Harbour measurements.

Setter-only regression: `python tests/setdate-bb/check.py --compiler ./hbc`
checks SET CENTURY ON/OFF and SET DATE without a later date-render call.
The blob must be included for those entry points too. Their empty outputs
are regression expectations, not new Harbour measurements. Linux checks
normal/instrumented and external-as paths; Windows execution is unverified.

`programs/setdate_empty.prg` renders the empty date in every SET DATE
layout, century off and on. Its `.windows.out` is a Harbour 3.2
measurement (mingw64, -gtcgi, native Windows 11, November 23, 2026);
the `.linux.out` has the same bytes with LF line ends.

The two original oracle programs above contain `Date()` and their pins
record November 23, 2026. They are not registered as timeless manifest
expectations. The Transform program is also outside the current Mach-O
contract, so it must not be silently added to the Mac battery.

## SET DATE order in CTOD, SET EPOCH, ALTD() (November 23, 2026)

Origin: a forum user's FEIERTAG.PRG (SET DATE GERMAN + CTOD("dd.mm.yyyy")).
Before this change CTOD ignored the SET DATE field order and always read
M D Y, so that call gave an empty date. Now CTOD reads the three digit runs
in the order of the active SET DATE format and applies a SET EPOCH pivot to
a year value below 100 (leading zeros do not matter: "0049" and "49" are
the same value, as the old default rule already measured through Year()).

Everything below is a HYPOTHESIS, not an oracle measurement (no Harbour was
available in the session and no source is linked for it):
- field order per format: MDY for AMERICAN/USA, DMY for BRITISH/FRENCH/
  GERMAN/ITALIAN, YMD for ANSI/JAPANESE;
- the pivot: century of the epoch year; a year below the epoch's last two
  digits goes to the next century (default epoch 1900, which keeps the old
  1900+yy result; epoch 1950: 49 -> 2049, 50 -> 1950);
- `ALTD()` as a statement does nothing. A user function ALTD overrides it
  (`tests/altd-user`). The value form (`? ALTD()`, `n := ALTD()`, `return ALTD()`,
  `ALTD(1)`) is a named compile error (`tests/altd-stmt/altd_value_*`).
- the Windows expectations of the new pins are the Linux bytes with LF ->
  CRLF; they have not been run on Windows.

`SET EPOCH TO <n>` takes an integer literal 0..9999. Anything else (a
negative number, a literal that overflows, 10000 or more, a non-literal,
a missing value) is a named compile error; it is never ignored and never
falls back to 1900. Pins: `programs/setdate_epoch_parse.prg` (orders,
pivot, "0049"/"049"/"49"), `programs/setdate_epoch_only.prg` (epoch set,
no date used and no output), `setter_only_date` (format set, no date used).

## CTOD of an untyped LOCAL (Dyn string)

`local cDate` (no initializer) then `cDate := STR(..) + "." + ..` then
`CTOD(cDate)` used to fail with `ctod expects a string`; because the
caller then also reported "`f` never returns a value", the real error was
hidden. Now CTOD accepts a Dyn variable holding a string, under the same
gate as UPPER/LOWER/ALLTRIM on a Dyn (ordinary Linux, no threads or macros;
other targets give that named rejection). A non-string Dyn at run time is
a named Limit message. The diagnostic fix reports the failing function's
own error instead of the caller's "never returns a value" symptom
(`tests/ctod-dyn/neg_masked_error.prg`). Pin: `tests/ctod-dyn/check.py`
(Linux only, not a manifest row). Hypothesis: nothing new beyond the
gate; the result bytes (`19.05.91`, `01.12.24` under SET DATE GERMAN) rest
on the field-order hypothesis above.

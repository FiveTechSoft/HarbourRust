# Day, Month, Dow, CDow, CMonth and DToC

Base: 2b88d86. These six date builtins complete the common accessors
around the existing packed Date scalar (YYYYMMDD, zero = empty date) and
the Date/CToD/Year/SToD/DToS/arithmetic increments.

## Semantics (pinned against real Harbour 3.2.0, r2607071000)

For CToD("11/15/2026"):

| call | result |
|---|---|
| Day(d) | 15 |
| Month(d) | 11 |
| Dow(d) | 1 (Sunday = 1 ... Saturday = 7) |
| CDow(d) | "Sunday" |
| CMonth(d) | "November" |
| DToC(d) | "11/15/26" (MM/DD/YY) |

Empty date (CToD("")): Day/Month/Dow answer 0, CDow/CMonth answer the
empty string, DToC answers eight bytes "  /  /  ". Names are English and
the DToC layout is the default Harbour MM/DD/YY rendering; SET DATE
formats and locales are outside this increment.

Days() was probed too: Harbour 3.2.0 answered 0 for every date tried,
so it is deliberately not implemented here rather than guessed.

## Implementation

- Day/Month divide the packed scalar; Dow calls the existing
  hbc_date_days (days_from_civil) and maps the remainder so Sunday = 1,
  including negative epochs via a Euclidean adjustment.
- CDow/CMonth return borrowed name pointers; the emitter copies them
  with hbc_strcpy because the expression type is an owned string.
- DToC allocates the eight-byte owned result with hbc_stralloc and
  writes the same digits/slashes as the native date renderer.
- Helpers are only emitted when a call site uses them (the existing
  DATE_PORT_HELPERS inclusion list was extended).

## Verified

Real Windows PE, instrumented: the oracle matrix above matches byte for
byte, including empty-date behavior. The existing date suite t1672-t1677
still passes 6/6, Day("x") rejects with "`day` expects a date", and the
new fixture tests/date-extra/datefns.prg is in tests/manifest.txt with
the oracle expectation. No full battery is claimed by this unit.

## Limits

Fixed English names and MM/DD/YY output, no SET DATE/locale handling, no
Days(), no date-to-string code page variants, and no new date arithmetic.

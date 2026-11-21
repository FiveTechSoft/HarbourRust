# Transform() - clean-room, black-box

`Transform(value, picture)` for typed numbers, strings, dates and logicals
with a typed string picture, on ordinary Linux (no threads) only. Dyn
values or pictures, two owned-temporary arguments, Windows, Mac and LLVM
keep named rejections.

Provenance: written only from the attached table of 49 observed
input/output pairs of Harbour 3.2.1dev (r2610242111) run as a black box.
No Harbour source, no GPL C and no earlier TRANSFORM implementation was
read. `runtime/hrtransform.c` is original MIT code; `generated/hrtransform.s`
is its gcc output (`tests/generate_transform_asm.py`, recipe in
`generated/hrtransform_recipe.json`). The compiler renders numbers with
Str() (picture width + 1, so a leading blank or zero can be dropped) and
dates with DToC(); the C code only lays the text out.

## Observed pins

`programs/transform_num.prg` (24 calls) and `programs/transform_text.prg`
(25 calls) match `expected/*.oracle.out` byte for byte: 49/49
(`tests/transform-bb/check.sh /path/to/hbc`). These files are the only
oracle evidence. `expected/smoke_unverified.hbc.out` is hbc's own output
for extra shapes and is NOT oracle output.

## Rules fitted to the observations (everything else is UNVERIFIED)

- Numbers: width = digit slots (`9 # * $`) + the first `.`; commas are not
  counted; decimals = slots after the first `.`. Overflow gives asterisks
  with the decimal point kept; a comma slot not preceded by a digit shows
  the fill. `*`/`$` slots replace leading blanks. `@Z` zero -> blanks, `@E`
  swaps `.`/`,`, `@X` appends ` DB` for negatives (sign dropped), `@C`
  appends ` CR` for non-negatives, `@(`/`@)` wrap negatives in parentheses
  (the first column becomes `(`). No picture body -> plain Str().
- Strings: `@!` upper-cases; without `@R` the result has min(len, picture)
  characters and non-slot picture characters replace the data; with `@R`
  non-slot characters are inserted, the result has the picture's length
  and missing data becomes blanks.
- Dates: the picture does not shape the text; `@E` swaps day and month.
- Logicals: `Y` in the picture gives Y/N, otherwise T/F.

## Not pinned by any observation (guesses, no oracle)

`@B`, `@L` (leading zeros), `@(`/`@)` for values that fit, `@X`/`@C`
interplay, non-slot literals in numeric pictures, a second `.` in a numeric
picture (one @E overflow row only: it takes one text column), `@A`, `@S`,
`@R` on numbers, empty strings and dates, SET DATE/DECIMALS/CENTURY state,
very wide pictures (internal buffer of 1024 columns), NIL and error cases,
Unicode. Str(0.5,3,2) is `***` in hbc; the picture `.99` is handled by
rendering one column wider, which this file does not claim matches
Harbour's Str().

## Bounds

Numeric pictures honour at most 500 body columns (the rest is ignored by
both `hbc_tr_dims` and the layout code); every buffer write is bounded by
that, and `tests/transform-bb/programs/bounds_unverified.prg` plus an
ASAN/UBSAN fuzz of `hbc_tr_apply` (200k random shapes, pictures to 3000,
text to 1500) pass. Very wide numeric pictures stop earlier in the
existing Str() ("float field out of range"). The date is rendered after the
picture is evaluated, so a throwing picture leaves nothing to release;
`throw_unverified.prg` loops 60k throwing calls without memory growth.
An owned temporary value needs a variable or literal picture.

## Row of the @E overflow case

Call 20 (1-based) of `programs/transform_num.prg`, source line 22:
`Transform(1234567.891, "@E 9.999.999,99")`. Its expected row is output
line 21 of `expected/transform_num.oracle.out` (line 1 is Harbour's leading
blank line): `[*,***,***** ]`.

## Evaluation order and ownership (v3)

A string value needs a variable or literal picture: a call in the picture
could free or change the borrowed value, or throw past an owned temporary.
`reject/*.prg` must not compile (owned value with a throwing picture,
borrowed value with a mutating picture). Number, date and logical values
may use any picture expression; the date is rendered only after the picture
is evaluated. `check.sh` compares the program rc, stdout and stderr.

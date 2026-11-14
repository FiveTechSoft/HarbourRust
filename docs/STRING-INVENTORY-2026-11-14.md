# Harbour string-function inventory - 14 November 2026

Reference: Harbour `694428e1c12f726675b19324d62167fa77d68185` and HarbourRust
`76d027ccdc0717318ddcf3a3bce58c2a353556bd` (SubStr published). This is a source
inventory, not a complete-library compatibility or upstream-admission claim.

## Scope and status

Included: every `doc/en` entry categorized Strings, public exports from the
core RTL text families listed below, and named adjacent conversion/encoding,
checksum/digest, memo-I/O and output-boundary families. Internal `__*` helpers
are excluded. Contrib libraries (for example hbct/xhb), network/file protocols,
GT/input UI, general date formatting and arbitrary functions that happen to
return text are separate inventories. Their absence here is not completion.
Runtime source paths below make the boundary reproducible. Aliases count as
API names, not as independent implementations. Optional build/codepage/regex
features may need additional Harbour build dependencies.

`partial` means an implemented bounded native path with limits, not full
Harbour arity/polymorphism/codepage/error behavior. `not implemented` means no
current native builtin admission found in the complete compiler source;
linked user-provided C extensions are not native builtin implementations.
No entry is promoted to fully implemented without a complete API audit.

Frequency columns are lexical call-like mentions after removing comments
and quoted strings in the pinned 1,041 `.prg` sources. They are prioritization
signals, not executed calls, a semantic call graph, or proof that implementing
one function admits the enclosing program. Declarations/macros/methods may
contribute lookalike names; all 1,041 files are counted, including contrib.
The 268 originals directly under `tests/` are a separate admission denominator.

## Counts

- 189 named APIs in this explicit scope.
- 23 partial native paths; 166 not implemented.
- 0 declared fully implemented by this inventory.

## Suggested order

1. Fix the independently reproduced post-TRY trace-chain crash first. Keep
   general owned-temporary exception cleanup a separate audited change.
2. Left/Right/At/RAt and Int/Val, followed by Upper/Lower/Space/StrTran/Stuff
   and complete Str/StrZero/padding conversions. Rank within a family by the
   source-hit columns and real ERP probes rather than claiming universal use.
3. Token/multiline, matching/regex, Unicode/codepage and serialization families.
   Encodings/digests/memo I/O remain explicit adjacent groups, not forgotten.
4. Contrib string libraries and remaining date/IO/terminal surfaces need their
   own inventories before any claim of all Harbour strings being complete.

Every future code package needs fresh Harbour differential output, final
ownership checks, honest limits and a representative microbenchmark reporting
ns/call or MB/s against Harbour. Include an equivalent C/Rust reference where
fair; preserve mutation safety, explain unavoidable copies, and optimize clear
losses before publishing. Benchmarks live outside the main regression manifest.

## Core slicing, search, editing

| API | Status | Call mentions / files | Harbour source | Scope |
| --- | --- | ---: | --- | --- |
| `SUBSTR` | partial | 1352 / 156 | `src/rtl/substr.c` | typed byte strings, integer start/count, 2/3 args; owned TRY error-path leak |
| `LEFT` | not implemented | 717 / 139 | `src/rtl/left.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `AT` | not implemented | 300 / 89 | `src/rtl/at.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `STRTRAN` | not implemented | 443 / 83 | `src/rtl/strtran.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `RIGHT` | not implemented | 212 / 75 | `src/rtl/right.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_LEFTEQ` | not implemented | 188 / 31 | `src/rtl/left.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `STUFF` | not implemented | 115 / 30 | `src/rtl/stuff.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `RAT` | not implemented | 58 / 20 | `src/rtl/rat.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_AT` | not implemented | 57 / 17 | `src/rtl/at.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_STRREPLACE` | not implemented | 43 / 14 | `src/rtl/strrepl.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_LEFTEQI` | not implemented | 14 / 9 | `src/rtl/left.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ATI` | not implemented | 8 / 8 | `src/rtl/ati.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_RAT` | not implemented | 11 / 2 | `src/rtl/rat.c` | no native builtin admission found in current hbc parser/checker/emitter |

## Case, classification, trimming, padding

| API | Status | Call mentions / files | Harbour source | Scope |
| --- | --- | ---: | --- | --- |
| `SPACE` | not implemented | 561 / 131 | `src/rtl/space.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `UPPER` | not implemented | 317 / 99 | `src/rtl/strcase.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `PADR` | partial | 599 / 93 | `src/rtl/padx.c` | typed string and integer width only; no custom pad or general numeric conversion |
| `LTRIM` | partial | 182 / 70 | `src/rtl/trim.c` | typed string only; bounded whitespace/codepage behavior |
| `ALLTRIM` | partial | 258 / 60 | `src/rtl/trim.c` | typed string only; no general optional extra trim-character handling |
| `REPLICATE` | partial | 154 / 60 | `src/rtl/replic.c` | typed string and integer count only; no numeric truncation/Dyn |
| `LOWER` | not implemented | 474 / 59 | `src/rtl/strcase.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `RTRIM` | partial | 124 / 55 | `src/rtl/trim.c` | typed string only; bounded whitespace/codepage behavior |
| `PADC` | not implemented | 108 / 26 | `src/rtl/padx.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `PADL` | not implemented | 64 / 17 | `src/rtl/padx.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `ISDIGIT` | not implemented | 62 / 13 | `src/rtl/is.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ASCIIUPPER` | not implemented | 15 / 7 | `src/rtl/hbascii.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `ISALPHA` | not implemented | 35 / 7 | `src/rtl/is.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ASCIIISALPHA` | not implemented | 6 / 3 | `src/rtl/hbascii.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ASCIIISDIGIT` | not implemented | 6 / 2 | `src/rtl/hbascii.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `ISLOWER` | not implemented | 21 / 2 | `src/rtl/is.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `ISUPPER` | not implemented | 21 / 2 | `src/rtl/is.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UPADR` | not implemented | 1 / 1 | `src/rtl/padx.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `PAD` | not implemented | 21 / 1 | `src/rtl/pad.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `TRIM` | partial | 18 / 1 | `src/rtl/trim.c` | typed string only; bounded whitespace/codepage behavior |
| `HB_ASCIIISLOWER` | not implemented | 0 / 0 | `src/rtl/hbascii.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ASCIIISUPPER` | not implemented | 0 / 0 | `src/rtl/hbascii.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ASCIILOWER` | not implemented | 0 / 0 | `src/rtl/hbascii.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BPADC` | not implemented | 0 / 0 | `src/rtl/padx.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BPADL` | not implemented | 0 / 0 | `src/rtl/padx.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BPADR` | not implemented | 0 / 0 | `src/rtl/padx.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UPADC` | not implemented | 0 / 0 | `src/rtl/padx.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UPADL` | not implemented | 0 / 0 | `src/rtl/padx.c` | no native builtin admission found in current hbc parser/checker/emitter |

## Numeric conversion and formatting

| API | Status | Call mentions / files | Harbour source | Scope |
| --- | --- | ---: | --- | --- |
| `HB_NTOS` | partial | 976 / 182 | `src/rtl/hbntos.c` | integer and selected Dyn integer cell only; float conversion not general |
| `STR` | partial | 853 / 141 | `src/rtl/str.c` | integer value and optional integer width only; no decimal-formatting third arg |
| `VAL` | not implemented | 413 / 96 | `src/rtl/val.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `INT` | not implemented | 305 / 89 | `src/rtl/round.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `STRZERO` | not implemented | 151 / 38 | `src/rtl/strzero.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `TRANSFORM` | not implemented | 680 / 32 | `src/rtl/transfrm.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_STRFORMAT` | not implemented | 544 / 30 | `src/rtl/hbstrfmt.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `ROUND` | partial | 160 / 17 | `src/rtl/round.c` | bounded typed numeric inputs/metadata; not full Dyn numeric dispatch |
| `HB_VAL` | not implemented | 1 / 1 | `src/rtl/val.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_NTOC` | not implemented | 0 / 0 | `src/rtl/hbntos.c` | no native builtin admission found in current hbc parser/checker/emitter |

## Byte, Unicode and codepage text

| API | Status | Call mentions / files | Harbour source | Scope |
| --- | --- | ---: | --- | --- |
| `CHR` | partial | 1163 / 138 | `src/rtl/chrasc.c` | integer only; byte modulo 256; numeric truncation/codepages not general |
| `HB_BCHAR` | not implemented | 484 / 55 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `ASC` | partial | 143 / 42 | `src/rtl/chrasc.c` | typed strings only; empty string -> 0; byte/codepage limits |
| `HB_BLEN` | not implemented | 87 / 36 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BSUBSTR` | not implemented | 117 / 26 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8TOSTRBOX` | not implemented | 83 / 25 | `src/rtl/cdpbox.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BCODE` | not implemented | 70 / 19 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8TOSTR` | not implemented | 60 / 19 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BLEFT` | not implemented | 30 / 18 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CDPSELECT` | not implemented | 40 / 18 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BAT` | not implemented | 8 / 8 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CDPUNIID` | not implemented | 7 / 5 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_STRTOUTF8` | not implemented | 10 / 4 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BPEEK` | not implemented | 10 / 3 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BRIGHT` | not implemented | 5 / 3 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CDPLIST` | not implemented | 3 / 3 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_TRANSLATE` | not implemented | 10 / 3 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UCHAR` | not implemented | 3 / 2 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ULEN` | not implemented | 13 / 2 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CDPEXISTS` | not implemented | 1 / 1 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CDPISUTF8` | not implemented | 1 / 1 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UAT` | not implemented | 2 / 1 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ULEFT` | not implemented | 1 / 1 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_USTUFF` | not implemented | 4 / 1 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_USUBSTR` | not implemented | 6 / 1 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8ASC` | not implemented | 1 / 1 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8AT` | not implemented | 9 / 1 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8CHR` | not implemented | 1 / 1 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8RAT` | not implemented | 9 / 1 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BPOKE` | not implemented | 0 / 0 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BRAT` | not implemented | 0 / 0 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BSTUFF` | not implemented | 0 / 0 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CDPCHARMAX` | not implemented | 0 / 0 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CDPINFO` | not implemented | 0 / 0 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CDPISCHARIDX` | not implemented | 0 / 0 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_STRISUTF8` | not implemented | 0 / 0 | `src/rtl/strutf8.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UCODE` | not implemented | 0 / 0 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UPEEK` | not implemented | 0 / 0 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UPOKE` | not implemented | 0 / 0 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_URIGHT` | not implemented | 0 / 0 | `src/rtl/chruni.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8LEFT` | not implemented | 0 / 0 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8LEN` | not implemented | 0 / 0 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8PEEK` | not implemented | 0 / 0 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8POKE` | not implemented | 0 / 0 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8RIGHT` | not implemented | 0 / 0 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8STRTRAN` | not implemented | 0 / 0 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8STUFF` | not implemented | 0 / 0 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_UTF8SUBSTR` | not implemented | 0 / 0 | `src/rtl/cdpapihb.c` | no native builtin admission found in current hbc parser/checker/emitter |

## Token, multiline and phonetic text

| API | Status | Call mentions / files | Harbour source | Scope |
| --- | --- | ---: | --- | --- |
| `HB_ATOKENS` | not implemented | 129 / 31 | `src/rtl/hbtoken.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `MEMOLINE` | not implemented | 20 / 9 | `src/rtl/mlcfunc.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `MLCOUNT` | not implemented | 17 / 8 | `src/rtl/mlcfunc.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_TOKENGET` | not implemented | 25 / 6 | `src/rtl/hbtoken.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HARDCR` | not implemented | 8 / 2 | `src/rtl/hardcr.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_MLEVAL` | not implemented | 2 / 1 | `src/rtl/mlcfunc.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_TOKENCOUNT` | not implemented | 3 / 1 | `src/rtl/hbtoken.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_TOKENPTR` | not implemented | 2 / 1 | `src/rtl/hbtoken.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `MEMOTRAN` | not implemented | 10 / 1 | `src/rtl/mtran.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `MLCTOPOS` | not implemented | 45 / 1 | `src/rtl/mlcfunc.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `SOUNDEX` | not implemented | 18 / 1 | `src/rtl/soundex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `MLPOS` | not implemented | 0 / 0 | `src/rtl/mlcfunc.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `MPOSTOLC` | not implemented | 0 / 0 | `src/rtl/mlcfunc.c` | no native builtin admission found in current hbc parser/checker/emitter |

## Escaping, serialization and byte transforms

| API | Status | Call mentions / files | Harbour source | Scope |
| --- | --- | ---: | --- | --- |
| `HB_VALTOEXP` | not implemented | 150 / 35 | `src/rtl/valtoexp.prg` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CSTR` | not implemented | 165 / 24 | `src/rtl/valtoexp.prg` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_STRSHRINK` | not implemented | 56 / 14 | `src/rtl/hbstrsh.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_VALTOSTR` | not implemented | 32 / 10 | `src/rtl/valtostr.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_STRTOEXP` | not implemented | 5 / 4 | `src/rtl/strtoexp.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_STRCDECODE` | not implemented | 1 / 1 | `src/rtl/strc.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_STRCLEAR` | not implemented | 2 / 1 | `src/rtl/strclear.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_STRDECODESCAPE` | not implemented | 0 / 0 | `src/rtl/strc.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_STRXOR` | not implemented | 0 / 0 | `src/rtl/strxor.c` | no native builtin admission found in current hbc parser/checker/emitter |

## Wildcard and regular expressions

| API | Status | Call mentions / files | Harbour source | Scope |
| --- | --- | ---: | --- | --- |
| `HB_REGEX` | not implemented | 15 / 9 | `src/rtl/hbregex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_REGEXCOMP` | not implemented | 24 / 8 | `src/rtl/hbregex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_REGEXSPLIT` | not implemented | 15 / 6 | `src/rtl/hbregex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_REGEXHAS` | not implemented | 5 / 4 | `src/rtl/hbregex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_REGEXALL` | not implemented | 11 / 3 | `src/rtl/hbregex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_REGEXLIKE` | not implemented | 7 / 3 | `src/rtl/hbregex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_WILDMATCH` | not implemented | 5 / 3 | `src/rtl/strmatch.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_REGEXMATCH` | not implemented | 5 / 2 | `src/rtl/hbregex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_WILDMATCHI` | not implemented | 5 / 2 | `src/rtl/strmatch.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_REGEXATX` | not implemented | 1 / 1 | `src/rtl/hbregex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ATX` | not implemented | 0 / 0 | `src/rtl/hbregex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISREGEX` | not implemented | 0 / 0 | `src/rtl/hbregex.c` | no native builtin admission found in current hbc parser/checker/emitter |

## Binary text encodings and numeric bytes

| API | Status | Call mentions / files | Harbour source | Scope |
| --- | --- | ---: | --- | --- |
| `HB_NUMTOHEX` | not implemented | 58 / 23 | `src/rtl/hbhex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_HEXTONUM` | not implemented | 16 / 10 | `src/rtl/hbhex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `BIN2L` | not implemented | 36 / 8 | `src/rtl/binnum.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BASE64ENCODE` | not implemented | 11 / 8 | `src/rtl/base64c.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_STRTOHEX` | not implemented | 19 / 8 | `src/rtl/hbhex.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `I2BIN` | not implemented | 24 / 8 | `src/rtl/binnum.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `BIN2W` | not implemented | 50 / 7 | `src/rtl/binnum.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_BASE64DECODE` | not implemented | 11 / 5 | `src/rtl/base64d.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `L2BIN` | not implemented | 25 / 5 | `src/rtl/binnum.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `BIN2I` | not implemented | 21 / 4 | `src/rtl/binnum.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_HEXTOSTR` | not implemented | 1 / 1 | `src/rtl/hbhex.c` | no native builtin admission found in current hbc parser/checker/emitter |

## Checksums and string digests (adjacent)

| API | Status | Call mentions / files | Harbour source | Scope |
| --- | --- | ---: | --- | --- |
| `HB_MD5` | not implemented | 8 / 4 | `src/rtl/hbmd5.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CRC` | not implemented | 1 / 1 | `src/rtl/hbcrc.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CRC32` | not implemented | 1 / 1 | `src/rtl/hbcrc.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CRCCT` | not implemented | 1 / 1 | `src/rtl/hbcrc.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_HMAC_SHA224` | not implemented | 1 / 1 | `src/rtl/hbsha2hm.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_HMAC_SHA256` | not implemented | 1 / 1 | `src/rtl/hbsha2hm.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_HMAC_SHA384` | not implemented | 1 / 1 | `src/rtl/hbsha2hm.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_HMAC_SHA512` | not implemented | 1 / 1 | `src/rtl/hbsha2hm.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_SHA1` | not implemented | 3 / 1 | `src/rtl/hbsha1.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_SHA224` | not implemented | 3 / 1 | `src/rtl/hbsha2.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_SHA256` | not implemented | 3 / 1 | `src/rtl/hbsha2.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_SHA384` | not implemented | 3 / 1 | `src/rtl/hbsha2.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_SHA512` | not implemented | 3 / 1 | `src/rtl/hbsha2.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_CRC16` | not implemented | 0 / 0 | `src/rtl/hbcrc.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_HMAC_MD5` | not implemented | 0 / 0 | `src/rtl/hbmd5.c` | no native builtin admission found in current hbc parser/checker/emitter |

## Memo text I/O (adjacent)

| API | Status | Call mentions / files | Harbour source | Scope |
| --- | --- | ---: | --- | --- |
| `HB_MEMOWRIT` | not implemented | 44 / 28 | `src/rtl/memofile.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_MEMOREAD` | not implemented | 52 / 25 | `src/rtl/memofile.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `MEMOREAD` | not implemented | 36 / 17 | `src/rtl/memofile.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `MEMOWRIT` | not implemented | 11 / 4 | `src/rtl/memofile.c` | no native builtin admission found in current hbc parser/checker/emitter |

## Length, emptiness, type and output boundaries

| API | Status | Call mentions / files | Harbour source | Scope |
| --- | --- | ---: | --- | --- |
| `LEN` | partial | 2351 / 321 | `src/rtl/len.c` | selected string/array/hash/Dyn shapes; parameter and temporary limits |
| `EMPTY` | partial | 1713 / 288 | `src/rtl/empty.c` | bounded scalar/variable aggregate shapes; literal aggregate restrictions |
| `HB_ISSTRING` | partial | 603 / 163 | `src/rtl/valtype.c` | selected scalar/Dyn/cell shapes; not unrestricted Harbour values |
| `HB_ISNUMERIC` | partial | 416 / 138 | `src/rtl/valtype.c` | selected scalar/Dyn/cell shapes only |
| `HB_EOL` | partial | 1051 / 106 | `src/rtl/console.c` | platform newline helper; full API audit not repeated here |
| `VALTYPE` | partial | 350 / 95 | `src/rtl/valtype.c` | selected expressions/cells only; many owned-call forms rejected |
| `HB_ISARRAY` | partial | 209 / 69 | `src/rtl/valtype.c` | selected scalar/Dyn/cell shapes only |
| `QOUT` | partial | 168 / 59 | `src/rtl/console.c` | bounded output-value shapes; no general object/error/terminal behavior |
| `HB_ISLOGICAL` | not implemented | 79 / 52 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISOBJECT` | not implemented | 124 / 42 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `OUTSTD` | partial | 229 / 39 | `src/rtl/console.c` | bounded output-value shapes; not unrestricted runtime values |
| `HB_ISBLOCK` | not implemented | 275 / 38 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISHASH` | not implemented | 44 / 28 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISEVALITEM` | not implemented | 71 / 27 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISDATE` | not implemented | 29 / 23 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `QQOUT` | partial | 53 / 21 | `src/rtl/console.c` | bounded output-value shapes; no general object/error/terminal behavior |
| `OUTERR` | partial | 100 / 17 | `src/rtl/console.c` | bounded output-value shapes; not unrestricted runtime values |
| `HB_ISNIL` | not implemented | 102 / 8 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISPOINTER` | not implemented | 8 / 7 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISNULL` | not implemented | 22 / 6 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISSYMBOL` | not implemented | 5 / 3 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISCHAR` | not implemented | 1 / 1 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISDATETIME` | not implemented | 1 / 1 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISMEMO` | not implemented | 1 / 1 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISTIMESTAMP` | not implemented | 2 / 1 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |
| `HB_ISHASHKEY` | not implemented | 0 / 0 | `src/rtl/valtype.c` | no native builtin admission found in current hbc parser/checker/emitter |

## Refresh protocol

Re-run export/doc extraction and lexical counts on the pinned Harbour tree,
validate any newer main source admissions, and retain the exact base hashes.
An implemented name moving to partial/full requires behavior evidence, not
just a symbol or a successful compile. Microbenchmarks are not compatibility
proof and exact output is not proof of leak-free exception cleanup.

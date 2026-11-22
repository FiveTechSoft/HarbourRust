# Val clean-room package

`hbc_val` (and its checker/codegen arms in src/hbc.rs) rewritten from a
black-box oracle spec ONLY. The previous implementation, the flagged
commit (f8540cff96744bec0ba08ef5201dbe2f06e242eb) and any Harbour
source were not read (disclosure: see below). The shared float parser
`harbour_parse_f64` is byte-for-byte unchanged; only its misleading
comment was replaced (it claimed Harbour's hb_str2number algorithm,
which the body does not implement).

## Oracle

- val-oracle-spec, spec tgz sha256
  `95247f25c93c01899034cfe86a949140565fc9d705e6c255831e983002d1b6e7`,
  971 cases. The oracle exercises `Val`, `Round`, `Str` and hb_ntos
  formatting together: each row records the Val result's type, raw
  value and formatted shapes.
- `expected/val_spec_adapted.oracle.out` is the oracle's `out.txt`
  verbatim (all 971 rows; the adaptations change how rows are PRODUCED,
  not the expected bytes).

## Check

    tests/val-bb/check.sh /path/to/hbc

Same protocol as tests/round-bb/check.sh: full adapted spec, probes
(leak + caught error paths), byte-compare against the oracle, require
the actual diff to be byte-identical to `pinned-diffs/full-spec.diff`
and `known-mismatches.txt` to name exactly the pinned row ids; a fresh
"any text fits" pin must be rejected. Rejection fixtures must fail with
rc 1, a named diagnostic and no panic. Current state:

    PASS full-spec (879/971 lines match, 92 pinned)
    PASS probes-leak (3/3 lines match, 0 pinned)
    PASS probes-errors (7/7 lines match, 0 pinned)
    PASS probes-args (4/4 lines match, 0 pinned)
    PASS val_reject_dyn (clean rejection)

check.sh also verifies that known-mismatches.txt documents exactly the
ids the pinned full-spec diff carries (and rejects a fresh "any text
fits" pin). The probes-args program is a SELF-PINNED regression probe:
its scenarios are outside the oracle's coverage (aliased and throwing
arguments, nested aggregates), so its expected file pins this
compiler's own verified output.

## Harness adaptations (all labelled in programs/val_spec_adapted.prg)

1. `Esc()`: no hb_NumToHex in this runtime; manual hex-nibble table and
   Int() wrappers. Same output bytes.
2. Four macro rows are written as direct calls with omitted arguments
   as explicit NIL, like the other macro rows: D_0322 (&("Val(Date())")
   -> Val(Date())), D_0323/D_0324 (extra arguments) and D_0325
   (&("Val(NIL,NIL)") -> Val(NIL,NIL)). D_0325 is NOT removed: it runs
   as ERR row 325 and matches the oracle. Dynamic dispatch of a
   NON-LITERAL numeric argument (Val(NumLocal(1)) style) stays a named
   compile-time rejection, pinned by `rejects/val_reject_dyn.prg`.
3. `Err()`: as in tests/atokens-bb (no error-object system; the caught
   value IS its description string and is compared against "Argument
   error"; operation/subCode/genCode (`VAL|1098|1`) are literal
   stand-ins and are not verified). The error is genuinely raised and
   caught in every one of the 14 ERR rows.

## Behaviour fitted from the oracle (design decisions + evidence)

| Decision | Evidence |
| --- | --- |
| Whitespace set is space plus bytes 9-13 (tab, LF, VT, FF, CR); other bytes are not whitespace | B_family rows (B_0674-B_0795) |
| Optional +/- after leading whitespace; "- 5" (space after sign) is invalid -> 0 | A_0017-A_0026 |
| Digits accumulate into an i64 while |x| <= 1e18-1, then the F64 route (x*10+d) | value+metadata A rows |
| Integer digits cap at 19 total; over 19 the dotless recompute below applies | A_0145-A_0165 |
| Decimal places: if a dot was scanned and no more digits follow, keep the first dot's position; if digits follow a later dot, recompute to the digits after the last dot | A_0140-A_0142, A_0143/A_0144 and value rows |
| Value of a dotted input = integer part divided once by 10^dec (correctly-rounded model; see deviation 2) | 179/182 correctly-rounded matches in the fitted sweep (val_fitted_detail.json) |
| Metadata len: no dot and |i| <= 9999999999 -> consumed-character count plus sign; dot present -> integer digits + 1 + dec | A/B metadata rows |
| |v| >= 9999999999.0 or <= -999999999.0 after division bumps len to 20 | A_0075-A_0104 |
| Dotless input whose digit count exceeds 19 recomputes the value with len 10 or 20 (20 when |v| >= 1e10 or <= -1e9) | A_0145-A_0165 |
| Integer type is reported when dec == 0 | oracle T column, I/N rows |
| 0 arguments or a non-string first argument: catchable "Argument error" | C_0299-C_0321, D_0322; probes-errors |
| Arguments beyond the first are evaluated and ignored | D_0323, D_0324 (literals; evaluation of the extras itself is UNVERIFIED) |
| Dyn/NumLocal arguments (other than a NIL literal) | named rejection; Harbour's dynamic dispatch is UNVERIFIED |

## Recorded deviations (92 rows)

Recorded as fixed deviations (model fitting was stopped in favour of
documentation accuracy). All 92 are pinned in
`pinned-diffs/full-spec.diff` and classified in
`known-mismatches.txt`. IMPORTANT: every one of the 92 rows changes
VISIBLE output bytes - none is metadata-only. The precise breakdown
(computed from the pinned diff, whitespace-insensitive comparison per
column):

1. Integer item vs F64 (2 rows). A_0051 (input "9007199254740993",
   2^53+1): the oracle keeps the exact integer and every column prints
   9007199254740993; this runtime's F64 rounds to 9007199254740992 in
   all 5 columns. A_0052 (input "9223372036854775807", i64 max): oracle
   prints the exact value, this runtime prints 9223372036854776000
   (columns 1, 2, 5; the fixed-decimal columns star-overflow on both
   sides). The T column is N on both sides in both rows.
2. Value evaluation, 1 ulp (45 rows). This runtime evaluates a dotted
   input as one correctly-rounded division n / 10^d; the oracle's value
   differs by 1 ulp. A repeated-division model was tested and REJECTED
   (175/182 rows matched vs 179/182 for the single-division model).
   The 1-ulp difference is VISIBLE in every one of the 45 rows
   (disjoint buckets, computed from the pinned diff):
   - 12 rows differ only in the 17-decimal image column (last digit):
     A_0166, E_0374, E_0375, E_0379, E_0397, E_0419, E_0571, E_0574,
     E_0575, E_0586, E_0588, F_0827.
   - 23 rows also change the shortest/Str display columns' final digits
     (large-magnitude or 15-16-digit values): A_0062, A_0069, A_0070,
     E_0634, E_0638, E_0643, E_0651, E_0653, E_0655, E_0675, E_0677,
     F_0737, F_0841, F_0854, F_0867 and the 8 O_set rows O_0882-O_0966.
   - 6 rows change an Int(v*10^k) result by a full unit in ALL columns:
     E_0347 (1005 vs 1004), E_0521 (435 vs 434), E_0543 (115 vs 114),
     E_0565 (820 vs 819), E_0587 (57 vs 56), E_0609 (1999 vs 1998).
   - 4 rows are equality/subtraction probes against literals: E_0644
     and E_0666 print .T. vs .F. only; E_0645 prints 0.0 vs 0.125 and
     E_0667 prints 0.00 vs 0.02 in every column (1 ulp at those
     magnitudes).
   12 + 23 + 6 + 4 = 45. Harbour's exact evaluation order is
   UNVERIFIED.
3. Default image width (45 rows, cols 2 and 5 only). The Str/hb_CStr
   default image carries a different amount of leading padding; the
   digits are byte-identical after removing whitespace. The oracle's
   width tracks the consumed character count (including leading
   whitespace and trailing junk) rather than the field width this
   runtime reports from the item metadata.

So: 45 rows differ only in whitespace padding, 47 rows change printed
digits or a logical result, and no claim is made that any deviation is
invisible.

## UNVERIFIED

- Windows/Mach-O runtime (no Wine in this environment): the Windows
  argument-error helper is written by analogy to the Linux one and is
  NOT verified.
- Harbour's exact double-evaluation order (family 2 above).
- Evaluation side effects of extra arguments and non-logical typing of
  arguments beyond the first.
- Dyn/NumLocal dynamic dispatch.
- Aliased argument shapes rejected at compile time in the hb_ATokens
  arm (a later argument consuming or rebinding a borrowed string
  argument) and owned-temporary-plus-raising-argument shapes; both are
  outside the oracle and are named rejections, pinned by
  tests/atokens-bb/rejects/ (see tests/atokens-bb/README.md).

## Disclosure (accidental contact with the old code / docs)

- The old hbc_val helper's leading comment block (which cited
  Harbour's hb_str2number and Str()/hb_ntos rules) was displayed once
  while locating the helper's boundaries for deletion. The body was
  deleted unread by computed line boundaries; the replacement was
  written from the oracle model above.
- The shared float parser harbour_parse_f64 carried a comment citing
  hb_str2number; the comment text was displayed while planning the
  replacement and is rewritten in this package. The parser body is
  untouched (byte-for-byte) and the new comment describes only what
  the body does.
- Two security-firewall notices flagged the round-bb README's
  "Disclosure" heading during the work; benign, no action taken. A
  third notice flagged this README's earlier attribution of the
  deviations decision to "the maintainer's instruction"; the wording
  now records the decision without claiming external authority.

## Gates

Same paired before/after gates as tests/atokens-bb (shared compiler):
unit 89/89 before and after; coverage census byte-identical to the
pinned base; full manifest sweep 1904 rows, 1900 PASS before and
after, zero changed rows; Wine-free battery leg 611 PASS before and
after with byte-identical failure sets; tests/round-bb/check.sh ALL
GREEN. Logs and the sweep driver are under
tests/atokens-bb/logs/gates/.

## Manifest and inventory

No tests/manifest.txt rows are added, removed, re-kinned or re-pinned
by this package, so the Mac inventory constants in
tests/run_macho_arm64.py are unchanged. The black-box programs run via
tests/val-bb/check.sh (same arrangement as tests/round-bb/).

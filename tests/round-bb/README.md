# Round() - clean-room, black-box

`Round(number, decimals)` for typed numbers, plus the display surface the
oracle exercises (`hb_ntos`, `Str`, `hb_CStr`, `Val`, `SET DECIMALS`), on
ordinary Linux (no threads). The Windows build carries the same clean-room
helpers (the per-target copies differ only in the fatal-error tail:
Linux `write`/`exit` syscalls vs `hbc_print_str`/`ExitProcess`), but no
Windows run was possible in this environment (no Wine), so Windows
behaviour is UNVERIFIED and the oracle pins Linux only. Mac and LLVM keep
their existing named rejections.

Provenance: written only from the attached black-box spec
(`round-oracle-spec-e8f27193.tgz`: 2146 cases with raw outputs from
Harbour 3.2.0 r2607071000, Linux x86-64 gcc, pure IEEE doubles; the tgz's
SHA256SUMS are kept with the package). No Harbour source, no GPL C and no
earlier Round implementation was read; the web was not searched for it.
The old helpers (an exact transcription of Harbour GPL code) were deleted
and replaced by original MIT code designed from the observable behaviour.

## Disclosure (required by the task)

Locating the call sites, a grep over `src/hbc.rs` surfaced label lines of
the old helpers (assembler label names and the interface region: the
`xmm0`/`rdi` argument convention, the packed `dec | len<<16` return, the
macro shim's `cvttsd2siq` truncation of the decimals argument and its
packing via `hbc_float_new`). Those are interface facts the task allowed
("find the call sites and the interface you need"). No old helper body,
comment body or constant table was read or used; the two tainted comment
sites that cited Harbour internals were replaced unread. Every behavioural
rule below is fitted to the oracle outputs, and each is re-derived from
oracle rows (the decimals-argument truncation, for example, is pinned by
the K section: `Round(x, 1.9)` behaves as `Round(x, 1)`).

## Observed pins

`tests/round-bb/check.sh /path/to/hbc` compiles and runs the 15 per-class
programs (`programs/round_A.prg` .. `round_O.prg`), the full adapted spec
(`programs/round_spec_adapted.prg`) and two regression probes, and checks
that every run exits 0 with empty stderr (oracle `rc.txt` = 0, `err.txt`
empty). The full `diff` of each run against the oracle columns under
`expected/` must be BYTE-IDENTICAL to the pinned diff under
`pinned-diffs/<label>.diff` (empty file = no deviations): this pins the
deviation ids, their content, their cardinality and their order, and a
consistency gate requires `known-mismatches.txt` to document exactly the
pinned ids. Result: 2173/2242 oracle lines match; the 69 differing lines
are listed in `known-mismatches.txt` with their family. Raw build/run
logs are under `logs/` (`full.build.log`, `full.run.stdout`,
`full.run.stderr`, `full.run.rc`, `full.diff.count`, `check.log`).

## Rules fitted to the observations (everything else is UNVERIFIED)

- Round value: `p = 10^|d|` (exact for `|d| <= 22`), `y = x*p` (`d >= 0`)
  or `x / p`; `y` is lifted by one ulp factor (`1 + 2^-52`,
  sign-symmetric); `a = |y| + 0.5`; truncate toward zero; restore the
  sign; unscale with a division (`r / p` or `r * p`). This matches the
  decisive rows: `Round(2.675,2)=2.68`, `Round(1.005,2)=1.01`,
  `Round(0.49999999999999994,0)=1`, negatives symmetric, `pi` at
  `d=16..256` displays one grid step up. `d > 308` produces a non-finite
  value (every `Str` width renders all asterisks, H_0676).
- Decimals argument: truncated toward zero (`1.9 -> 1`, `-1.5 -> -1`).
  Fewer than two arguments, a literal NIL in either position, or a
  non-numeric first argument is the catchable runtime error
  "Argument error" (spec ERR rows; the error fields are a harness
  adaptation, see below). Extra arguments are accepted and their values ignored
  (`Round(1.5,1,2)=1.5`, L_1064), but they ARE evaluated for their
  effects: the Harbour VM evaluates every argument before the call.
  UNVERIFIED contrast: whether Harbour evaluates an extra argument
  cannot be derived from the oracle (the L_1064 third argument is a
  literal, with no observable effect); this package EVALUATES extras
  in argument order, and pins that behaviour in
  `round_probes_fixes.prg` (`Round(1.5,1,Boom())` runs Boom and prints
  1.5). The first two arguments are likewise always evaluated before
  the argument error, pinned in the same probe (`Round(Boom(),2)` and
  `Round(1.5,Boom())` both run Boom and raise "Argument error").
- Checker contract (shape AND semantics): EVERY argument is fully
  type-checked - the first argument even in a one-argument call, the
  second argument also when the first is Dyn/NumLocal, and every
  extra, statically valid call or not. Checker, apply_moves and
  codegen see the same validated argument list, and codegen evaluates
  every argument apply_moves walked: an unknown call, an unknown
  variable or a builtin with a bad arity in ANY position is the
  generic checker's named error, never a downstream panic (pinned by
  `tests/round-bb/rejects-sem/`, including extras of statically valid
  calls), and a move marked inside an extra is a REAL move - pre-v8,
  `Round(1.5,1,Consume(s))` marked `s` moved even though the extra
  never ran, so a later read of `s` was rejected while the value was
  still alive (phantom move; now the same rejection reflects a real
  move, pinned by `round_reject_sem_extramove.prg`). A dynamic dec
  (Dyn or NumLocal, anything but a literal NIL) is a named rejection
  whatever the first argument's type - including a Dyn first argument,
  whose dispatch path does not unpack a dynamic dec (pre-v7 it read
  the tag word as the decimals count: `Round(a,d)` with two Dyn values
  printed 1.500000000 for d=2).
- Result metadata: `dec' = max(d, 0)`; `len` is 20 above
  `9999999999.0` / below `-999999999.0`, else 10. Display width is
  `len + 1 + dec` when `dec > 0`; overflow renders asterisks.
- Numeric arguments of every type go through the same double path:
  integer arguments are converted to double (`cvtsi2sd`) before
  rounding; there is no separate integer-arithmetic branch. The J
  section pins the resulting behaviour for integers a double holds
  exactly; at 2^53 and beyond the conversion is observable (the
  F_0471 family sits in the known mismatches for exactly this reason).
- f64 display image (hb_ntos, `?`, Str): the exact 16-significant-digit
  round-half-up image of the original value (decimal exponent counted on
  a copy, one 128-bit `M*5^k` step into `[1e15, 1e16)`; integral values
  up to 2^63-1 take an exact integer path, values past it a normalized
  fallback whose last digit can drift - see the F family note below).
- `Str(v, w, d)` (explicit decimals): `t = |v| + 0.5/10^d` as a double
  add (the perturbation decides boundary cases: `Str(9.995,10,2)` is
  `"10.00"`, M_1226), skipped when `|v|` is integral
  (`Str(5000,30,12)` keeps `"5000.000000000000"`, E_0320); the exact
  image is then TRUNCATED at `d` (`Str(9.995,20,15)` is
  `"9.994999999999999"`, M_1235). `Str(v)` / `Str(v, w)`: no add, the
  image is rounded half-up at the metadata decimals.
- Division result metadata: `dec` = the current runtime `SET DECIMALS`
  value (default 2; `SET FIXED` is irrelevant, O section). Literal
  `dec` = the written decimals; add/sub take `max`; `Val` takes the
  token's decimals and a length of `strlen - (dec+1 if dec>0)`.
- Literal parse: accumulate-then-divide while the accumulator is below
  2^53, a correctly-rounded parse beyond it (F_0442).

## Design decisions and rejected alternatives (provenance)

Every rule above was chosen against the oracle rows with a simulator
(`fullsim.py`, shipped in this directory, scored candidate rule sets
against all spec cases before
anything was ported to assembler). fullsim.py is an APPROXIMATE
simulator, not a proof: Python float exponentiation and the assembler
repeated squaring can differ by ulps in extreme cases; the K/L
invalid-shape rows and the macro rows are covered by the compiled
harness (check.sh), not by the simulation; and the 96 duplicated
O-section IDs are scored per evaluation, so those pairs weigh twice in
every score. It informed the design choices below; it is NOT evidence
of clean-room separation or licence status. The load-bearing choices:

| Decision | Chosen rule | Oracle evidence | Alternatives tried (sim score) |
| --- | --- | --- | --- |
| Pre-rounding lift | `y *= (1 + 2^-52)`, one ulp factor, sign-symmetric, applied BEFORE the `+0.5` | halves at 2^53 scale stay observable (`Round(9007199254740992.5,0)` -> ...994); `Round(999999999999999.5,0)` -> 1e15 | no lift (1955, misses the half rows); larger lifts (break exact rows) |
| Half handling | `a = |y| + 0.5`, truncate, `copysign` | A/B/C half sections, negatives symmetric | round-half-even image (2083, loses the A/B tie rows) |
| Unscale | division `r / p` (and `r * p` for `d < 0`) | aggregate over C/F/N | multiply by reciprocal `r * (1/p)`: 2060 vs 2086, loses rows |
| `Str` 3-arg rounding | double half-add perturbation (skipped when `|v|` is integral), then truncate at `d` | M_1226, M_1235, E_0320 | lift inside Str (`str3lift`): 1695, breaks hundreds of M rows |
| Image digits | exact 16-significant-digit half-up image from the original value | C/F/M columns, hk301 family | 15-digit threshold (`halfth=15`): 2093 sim, +7 C col4 rows but trades N_2026/N_2015; NOT ported - the col4-noise fit was capped at one run and the trade was not worth the rows it moved |

Nothing here is claimed to be the only model that fits. The 69 known
mismatches below are recorded deviations of THIS chosen model from the
oracle on those rows, not proven impossibilities; a different model may
fit some of them, and the sim data above shows the trades we measured.
The scores above are RE-MEASURED with the shipped simulator: run
`python3 tests/round-bb/fullsim.py results.tsv out.txt log-out`;
`logs/gates/fullsim-results.txt` records the per-variant scores, the
per-case baseline verdicts, and the sha256 of `fullsim.py` and both
oracle inputs. The baseline flags match the PORTED Str() 3-arg rule exactly:
`halfskipint` ON (the assembler skips the double half-add when `|v|` is
integral, E_0320), truncate at `d` (M_1235). Every one-change variant
adds its flag on top of that baseline, so each score reads as "ported
rule, one thing changed". The earlier `str3round` approximation
(round_alg first, no skip-when-integral) is kept as a named variant for
contrast (2062) and is NOT the ported rule. Scores: baseline 2086,
no-lift 1955, half-even 2083, multiply-unscale 2060, str3lift 1695,
halfth15 2093. The decision-time quotes (2080/2077/1580/2087/...) were
measured with a baseline whose flags did NOT model the
skip-when-integral rule; with the flags corrected the numbers above are
the honest ones, and every ordering behind a decision is unchanged
(baseline best; halfth15 higher but NOT ported, see the table). The 96
duplicated O-section IDs (same expression and SET evaluated twice, one
formatted N row plus one raw hb_CStr row) are scored per evaluation, so
the O pairs WEIGH TWICE in every score above.

## Harness adaptations (documented, all in programs/round_spec_adapted.prg)

The adapted spec is the oracle's `round_spec.prg` with three labelled
adaptations; the original spec files are untouched in the tgz.

1. `Err()`: this compiler has no error-object system; a caught value IS
   its description string. The adapted `Err()` COMPARES the captured
   string against the one the oracle row implies - "Argument error" for
   the Round argument/type errors, "Error: division by zero" for the
   `1/Round(-0.4,0)` case (N_2048) - and prints a visible
   `|ERR-DESC-MISMATCH|` marker (which fails the byte compare) if it
   differs. The remaining printed fields (`ROUND|1094|1`,
   `Zero divisor|/|1340|5`) are literal stand-ins: the runtime's caught
   value carries no operation/subCode/genCode, so those columns are not
   verified. The error itself is genuinely raised and caught in every
   one of the 24 ERR rows; strengthening the description check exposed
   and fixed one real deviation during review (literal `NIL` as the
   first argument raised "Type error: NIL used as a number" instead of
   "Argument error", oracle L_1046/1047).
2. `hb_SToD('20200101')` (2 rows): NOT an identity. Harbour's
   `hb_SToD` produces a DATE value and `Round` rejects it with
   "Argument error". This runtime DOES have a date type (`Date()` /
   `hb_SToD` return real `Ty::Date` values), and the genuine
   date-rejection path is verified directly:
   `Round(hb_SToD('20200101'), 2)` raises "Argument error", pinned in
   `programs/round_probes_errors.prg` (caught4) alongside the spec's
   own `Round(Date(), 0/2)` rows (L_1054/1055, caught3). The two
   adapted spec rows keep their earlier form - converting the date to
   its string form BEFORE the call (`Round('20200101', ...)`) - which
   takes the same argument-error path (non-numeric first argument);
   the direct date form is the pinned probe above.
3. Four macro rows (`&("Round(...)")`, L_1062..L_1065) are written as
   DIRECT CALLS: statement-context macro evaluation is outside this
   compiler increment (a documented capacity limit; the expression-
   macro path exists but these rows invoke `Round` as a statement).
   The macro dispatch itself is therefore NOT verified by this
   package. The underlying behaviour matches the oracle byte-for-byte
   through direct calls, including the two rows where the oracle shows
   that a third argument is accepted and ignored (L_1064 `Round(1.5,1,2)`
   -> 1.5, L_1065 `Round(2.5,0,NIL)` -> 3). What those rows do NOT
   pin is evaluation of the extra argument itself (both are literals);
   see the UNVERIFIED contrast note in the rules above.

The `Str()` width/dec sizing the spec's `Show()` exercises
(`Str(r,30,12)`, `Str(r,34,17)`) is not an adaptation: it is product
behaviour of this package, fitted to the same oracle, and documented in
the helper's header comment and the rules above.

## Existing manifest rows changed by this package

`tests/manifest.txt` before/after evidence: the full Linux-leg sweep is
in `logs/gates/manifest-sweep-base.json` (base d65a8392: 1904 rows,
1900 PASS) and `logs/gates/manifest-sweep-head.json` (this package:
1904 rows, 1900 PASS), driven by the shipped `logs/gates/sweep.py`
with per-row rc and stdout/stderr sha256 in the `*-detail.json` files;
the only row-set differences are the retired `t846_trace_while.prg`
below and the added rejection row `t1710_round_arrlit_neg.prg`, and
the four non-PASS rows in each run are identical on base and head
(3 neg rows needing Wine tooling, 1 environment procmeta row). The
expectations below were RE-PINNED by this package (they are not
inherited bytes). The Wine-free leg of the real battery is in
`manifest-base.log` / `manifest-head.log` (610 PASS base / 611 PASS
after - the added t1710 row - with byte-identical failure sets). Every row whose expectation the Round
work made obsolete is listed here - the complete list, not a sample:

Compile-time rejections relaxed (the spec requires these to compile):

- `t747_set_decimals.prg`: `neg` -> `pos` (empty output). `SET DECIMALS
  TO n` is now runtime state (O section pins the semantics).
- `t836_round_type_neg.prg`: `neg` -> `posx` rc=1. `Round("x",2)` now
  compiles and raises the oracle-pinned "Argument error" at run time;
  the row pins our unhandled-error print, which is our own format, not
  oracle output.
- `t837_round_dec16_neg.prg`: `neg` -> `pos`. `|d| > 15` is admitted;
  the expected image is pinned by H_0701/H_0663.

Rows whose expectation was the removed "round dec out of range" error
(`|d| > 15` is admitted now, oracle H section):

- `t838_round_rtdec_pos.prg`, `t840_trace_nested.prg`,
  `t841_trace_recursion.prg`, `t842_trace_block.prg`,
  `t843_trace_origin.prg`, `t845_trace_byref.prg`,
  `t847_trace_nested_expr.prg`, `t1014_pp_warning_trace_origin.prg`:
  `posx` -> `pos`; each pins the oracle-derived output of its
  `Round(1.5,16)` call (H_0701) plus the program's remaining output.
  `t839_round_rtdec_neg.prg` (`Round(1.5,-16)`) is not individually in
  the oracle; its pinned output `0` follows the documented model
  (UNVERIFIED).
- `t844_trace_unlink.prg`, `t848_trace_block_unlink.prg`: `posx2` ->
  `pos2`; Linux expectation files regenerated (the Round line is
  oracle-pinned); the Windows files carry the same bytes and stay
  UNVERIFIED (no Windows run in this environment).
- `t1710_round_arrlit_neg.prg`: ADDED (`neg`). `Round({1,2},0)` is a
  clean compile-time rejection ("not covered in this increment") -
  non-empty array literals, hash literals and whole static-array
  arguments have no expression lowering (the compiler's ArrLit/
  HashLit/Arr arms are unreachable); these shapes are outside the
  oracle (which exercises only `{}`), so this is a named rejection of
  this increment, NOT a claim of oracle equivalence. Admission is ONE
  recursive classifier (`round_lowering_gap`) applied UNCONDITIONALLY
  to every argument of every `Round` call - any arity, any static
  types, statically valid or not - walking the whole expression tree
  (`Seq` wrappers and nested call argument lists included); the
  codegen arm asserts the same classifier, so the two cannot drift.
  The pinned shapes in `tests/round-bb/rejects/` (check.sh requires
  rc 1 with the named diagnostic, fails on any compiler panic):
  literal in value position, literal in dec position, arity-1 call,
  static-array variable, extra argument in the invalid path, extra
  argument in the STATICALLY VALID path (its value is ignored; the
  no-lowering shape is rejected all the same), Dyn-dec dispatch, Dyn
  first argument
  with an invalid second argument and a literal extra (the discard
  path evaluates every argument), and a literal wrapped in a `(a, b)`
  sequence expression.
- `t846_trace_while.prg`: RETIRED (honest rejection, not dropped - the
  row is a manifest comment now, the program kept). Its `while` loop
  exited through the removed error; with the error gone the program
  does not terminate, so there is no finite output to pin. Note the
  trace rows no longer exercise callstack-at-error shapes either (they
  are positive rows now); the unhandled-error callstack format is
  pinned by t836 alone.

Rows re-pinned to the chosen display model (their old expectations were
generated by the deleted Harbour-derived code; the new outputs are
recorded deviations of the chosen model where they differ from
Harbour's double-rounded decimal conversion - see the family notes -
and none of these exact literals is individually in the oracle, so the
pins are UNVERIFIED unless noted):

- `t732_float_frontier_neg.prg` `9999999999999999.9 ->
  10000000000000000.0`, `t734_float_frontier2_neg.prg`
  `1234567890123456.7 -> 1234567890123457.0`,
  `t736_float_starzone_neg.prg` `99999999999999.99 ->
  99999999999999.98`, `t737_float_starzone2_neg.prg`
  `9999999999.999999 -> 9999999999.999998`,
  `t743_float_dec18_neg.prg` `0.000000000000000009 ->
  0.000000000000000009` (re-added as `pos` rows after review; the
  literal-parse rule above is the model they follow).
- `t735_float_carry10.prg`, `t739_float_carry16.prg`,
  `t741_float_parse_hk289.prg`, `t742_float_frontier_hk290.prg`
  (17-significant-digit literal parse + image; Linux expectation files
  regenerated, Windows files carry the same bytes UNVERIFIED).
- `t749_div_length.prg`: exposed a REAL bug fixed during review - the
  f64 image digit count stopped at 1e18 and imaged 19-digit integral
  values one digit short (`2^63-1 / 3` printed with a leading zero).
  The pinned output `3074457345618258000.00` is the correctly rounded
  16-significant-digit image. This fix also moved F_0498/F_0499
  (`Round(1e18,0/2)`) from known-mismatch to byte-identical.
- `t753_float_rounding.prg`: plain `?` display of computed halves.
  `9.995/1` prints `9.99` under the exact-image model where Harbour's
  conversion prints `10.00` (its internal double rounding lands on the
  tie; recorded deviation, hk301 family). `Str(9.995,10,2)="10.00"` is
  unaffected (M_1226 goes through the explicit half-add path).
- `str-decimals/strfmt.prg` v27 (`Str(Val("-999999999.5"))` field
  width) and v30 (`Str(Val("12345678901234567890"))`: 20 digits, past
  i64; the normalized fallback image's last digit is a recorded
  deviation).

- `t994_inline_if_missing_condition_neg.prg` still rejects: a literal
  or empty NIL `iif` condition keeps its static rejection (a Dyn
  condition reads its logical payload at runtime).

## Known mismatches (69 rows, recorded deviations of the chosen model)

`known-mismatches.txt` lists every differing id; `pinned-diffs/` carries
the exact byte-level diffs the check enforces. The families:

- `col4-17th-digit-noise` (C: 24 rows, N: 1 row): the 17th significant
  digit in `Str(r, 34, 17)` differs by one unit (e.g. C_0117 shows
  `...010` where the exact double image gives `...000`). The chosen
  exact-image model deviates here; the 15-digit-threshold variant above
  fits 7 more of these rows but trades N rows, so it was not adopted.
- `F-large-no-double-can-hold` (29 rows): literal/integral values whose
  exact decimal expansion no double can hold; the oracle's digits
  reflect Harbour's own decimal conversion of those values, which the
  chosen double model does not reproduce bit-for-bit (e.g. F_0442,
  F_0471, F_0472).
- `last-ulp-high-dec` (H: 12, G: 2): rounding/display at 15-17 decimals
  where the oracle shows digits the chosen model produces differently
  (e.g. `Round(2/3,16)` col3 `0.666666666667`).
- `unscale-tension` (N_2039, 1 row): `Int(Round(0.285,2)*100)=29` would
  need the multiply-by-reciprocal unscale, which the aggregate sim
  rejected (2060 vs 2086); the division unscale was adopted and this
  row records the cost.

## Bounds

`|d| > 22` uses the natural double computation of `10^|d|` (`d > 308`
non-finite). Star fields wider than the compose scratch are filled
through a heap path (oracle H_0676 pins a 1011-asterisk field), so the
old 456-byte print frontier no longer bounds star output; the scratch
bound still applies to non-star images. All other pre-existing compiler
limits are unchanged. The Windows target was not run (no Wine); Dyn
values, threads, Mac and LLVM are outside this package.

## Regression probes (review-driven)

`programs/round_probes_fixes.prg` pins: a heap-float Dyn through
`hb_ntos`/`hb_CStr` outside the spec's `Show` path (the owned-Dyn
release order), `hb_CStr`'s owned-copy contract on a literal, an owned
Dyn string, a StrOwn VARIABLE (`s2 := "a"+"b"`, read after the call)
and a static StrOwn TEMP (`hb_CStr("x"+"yz")`), that `Round` evaluates
EVERY argument's effects in order before raising the argument error,
and (UNVERIFIED contrast, see the rules) that an extra argument IS
evaluated, in argument order, when the first two are valid.
`programs/round_probes_owned.prg` applies `hb_ntos`/`hb_CStr` DIRECTLY
to owned heap-float Dyn temporaries (`Id(0.1+0.2)`, `Id(2.675)`,
`Id(1e15+0.5)`). Note: on this allocator the pre-fix use-after-free is
NOT byte-observable (the freed bytes survive long enough), so the
pre-fix and fixed compilers print identical bytes for these probes;
their value is exercising the owned path under the fixed release order
(and under any future allocator/instrumentation where reuse is
visible). `programs/round_probes_errors.prg` pins the
caught-description strings the strengthened `Err()` relies on
(including the genuine date-rejection path
`Round(hb_SToD('20200101'),2)`) plus runtime fixtures for every
admitted invalid shape with lowering: the empty-array literal in
either position, a dynamic-array variable, a hash variable and a
codeblock all raise the same "Argument error". Shapes WITHOUT
lowering (non-empty array literals, hash literals, whole static-array
values, by-reference forms outside a call argument) are clean
compile-time rejections from the single recursive classifier
`round_lowering_gap`, applied to every argument at every depth
regardless of arity, static types or static validity; the nine
fixtures in `tests/round-bb/rejects/` pin the shapes (check.sh
requires rc 1 with the named diagnostic and fails on any compiler
panic), and the codegen arm asserts the same classifier so the
checker and codegen share one definition. `programs/round_probes_leak.prg`
loops `Round(Id(0.1+0.2),"x")` and `Round(Id("abc"),"x")` in TRY
blocks and pins `hb_memcheck()` pending 0 after the baseline: the
invalid-argument path releases owned Dyn temporaries (the pre-fix
compiler leaks 1000 allocations over the same probe). Raw owned
temporaries of every admitted type are released too (empty array `{}`
via hbc_free, float arrays via hbc_float_cells_release + hbc_free,
Dyn/string/2..4-level arrays via hbc_dfree/hbc_sfree/hbc_free2/
hbc_rfree, hashes via hbc_hfree, objects via hrobj_release), pinned by
the `{}` shapes in this probe (oracle shapes L_1052/L_1053/K_1039; base
d65a8392 rejected them at compile time, so admitting them must not
leak). All probes are byte-pinned by `check.sh` like the spec programs;
raw execution records (stdout/stderr/rc per probe, plus the pre-fix vs
post-fix leak comparison) are in `logs/probes/`.

## dist/build.bat line endings (bundle vs archive)

`dist/build.bat` is UNTOUCHED by this package: the committed blob is
byte-identical to base d65a8392 (sha256
e95120e04682931073e95ce6049882e4d052a9e51d8fbca3b24119fc6b927cbe in
both) and carries LF endings. A `git archive` export converts it to
CRLF because `.gitattributes` marks it `eol=crlf`
(sha256 431658fe0cd27d8fd58a5942e4a5ff20381f99dec33872ef903e2cac49ec2e44
after export); a base archive shows the same converted bytes. So the
bundle carries LF, the tar carries CRLF, and that is the only
difference - an export conversion, not an edit.

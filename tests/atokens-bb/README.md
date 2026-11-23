# hb_ATokens clean-room package

`hbc_atokens` (and its checker/codegen arms in src/hbc.rs) rewritten
from a black-box oracle spec ONLY. The previous implementation, the
flagged commit (c89a935cc9a914c88848807f017d0453b9ba263c) and any
Harbour source were not read (disclosure: see below).

## Oracle

- atokens-oracle-spec, spec tgz sha256
  `61379fbbcc25b0a677281d09f73c8c35675771677a7c88aa26d6c8f14e58c0b3`,
  1650 cases. The oracle function is `hb_ATokens`; plain `ATokens` does
  not exist in Harbour 3.2.0 (oracle row D_1644).
- `expected/atokens_spec_adapted.oracle.out` is the oracle's `out.txt`
  minus row D_1644 (adaptation 3 in the spec program header).

## Check

    tests/atokens-bb/check.sh /path/to/hbc

Compiles and runs the full adapted spec and the regression probes,
byte-compares stdout against the oracle, and requires the diff against
the oracle to be byte-identical to the pinned one under `pinned-diffs/`
(empty files here = no deviations). Rejection fixtures must fail with
rc 1, a named diagnostic and no panic. Current state:

    PASS full-spec (1649/1649 lines match, 0 pinned)
    PASS probes-leak (3/3 lines match, 0 pinned)
    PASS probes-errors (5/5 lines match, 0 pinned)
    PASS probes-args (5/5 lines match, 0 pinned)
    PASS probes-args-instrumented (real byte sizes validated)
    PASS atokens_reject_alias (clean rejection)
    PASS atokens_reject_dyn (clean rejection)
    PASS atokens_reject_quiet_dyn (clean rejection)
    PASS atokens_reject_quiet_nil (clean rejection)
    PASS atokens_reject_quiet_nil_agg (clean rejection)
    PASS atokens_reject_quiet_nil_chr (clean rejection)
    PASS atokens_reject_throw (clean rejection)
    PASS atokens_reject_undef (clean rejection)

check.sh also verifies that known-mismatches.txt documents exactly the
ids the pinned full-spec diff carries (both empty here). The
probes-args program is a SELF-PINNED regression probe: its scenarios
are outside the oracle's coverage (throwing arguments, nested
aggregates, result-block sizing), so its expected file pins this
compiler's own verified output. Its instrumented run validates the
result block's REAL byte sizes through the (base, bytes) registry: the
result is exact-sized (header = live count = capacity, the
hbc_aclone_s invariant), not the scan's worst-case reservation.

## Harness adaptations (all labelled in programs/atokens_spec_adapted.prg)

1. `Esc()`: no hb_NumToHex in this runtime; manual hex-nibble table and
   Int() wrappers so Chr()/SubStr() get integers. Same output bytes.
2. Four macro rows written as direct calls; omitted arguments written
   as explicit NIL (Harbour's meaning of omission).
3. Row D_1644 (macro `ATokens("a b")` -> Harbour runtime "Undefined
   function") is not an output row: HarbourRust has no plain ATokens
   builtin, so the equivalent guarantee is a COMPILE-TIME named
   rejection, pinned by `rejects/atokens_reject_undef.prg`.
4. `Show()`'s array branch is inlined per case: array-view parameters
   are not in this increment. Every success row in the oracle output is
   an "A" row, so Show's non-array branch is dead here.
5. `Err()` (round-package shape): this runtime has no error-object
   system; a caught value IS its description string and is COMPARED
   against "Argument error" (the only description the oracle reports
   for hb_ATokens). operation/subCode/genCode (`HB_ATOKENS|1123|1`)
   are literal stand-ins: the runtime's caught value carries no such
   fields, so those columns are not verified. The error itself is
   genuinely raised and caught in every one of the 17 ERR rows.

## Behaviour fitted from the oracle (design decisions + evidence)

| Decision | Evidence |
| --- | --- |
| Default: single-space separator, empty tokens dropped; no tokens at all yields exactly one empty token | A_0001-A_0005, A_0036 |
| String separator: full multi-byte match, empty tokens kept | A/B sections, e.g. A_0106-A_0110, B_delim rows |
| EMPTY separator string falls back to the default | A_0066-A_0070, A_0171-A_0175 |
| Logical .T. separator: single whole-string token | C_1607, C_1637, C_1638 |
| Non-string, non-logical separator (NIL, .F., numbers, dates, arrays, blocks): the default | C_types rows |
| lSkipStrings skips quoted stretches; quote bytes " and ' ; lDoubleQuoteOnly restricts to " | A_0634, A_1019, SK matrix rows |
| Quote state is flat: opens anywhere including mid-token, closes on the same byte, unterminated runs to the end | A_0668, A_0703, A_0738 |
| [ ] and backtick are NOT quotes | A_0946, A_0981 |
| No argument or a non-string first argument: catchable "Argument error" | C_1600-C_1636, D_1641; probes-errors |
| Arguments beyond the fourth are evaluated and ignored | D_1642, D_1643 (literals; evaluation of the extras itself is UNVERIFIED - the oracle cannot distinguish it) |
| lSkip/lDQOnly of a non-logical static type count as .F. | UNVERIFIED: the oracle exercises only logicals there |
| Dyn/NumLocal arguments (other than a NIL literal) | named rejection; Harbour's dynamic dispatch is UNVERIFIED (oracle exercises static types only) |
| A later argument that consumes or rebinds a borrowed string argument (hb_ATokens(s, Consume(s))) | named rejection (atokens_reject_alias): the arm holds the string pointer until every argument is evaluated; aliasing is outside the oracle |
| An owned string temporary followed by an argument that can raise (hb_ATokens("a"+"b", Round())) | named rejection (atokens_reject_throw): no unwind cleanup in this increment. Non-raising = string/numeric/logical/NIL literals, variables of concrete static type (never Dyn/NumLocal), aggregates of those, and `+`/chr() whose OPERANDS are coercion-safe (string or numeric literals, concrete-typed variables, recursively): a bare NIL literal is quiet as an argument or aggregate element (its discard never raises), but NIL is Dyn-typed, so "x" + NIL, {"x" + NIL} and chr(NIL + 1) are named rejections (atokens_reject_quiet_nil*) even where the static result type is concrete - the coercion itself raises at runtime |

Result layout follows the compiler's existing DArrS convention (count
header at cells-8, then 16-byte {tag 2, payload} cells of owned
hbc_strcpy copies, released by hbc_sfree); the layout was taken from
the compiler's own hbc_aclone_s/hbc_sfree interface, not from any
Harbour source.

## UNVERIFIED

- Windows/Mach-O runtime (no Wine in this environment): the Windows
  argument-error helper is written by analogy to the Linux one and is
  NOT verified.
- Items marked UNVERIFIED in the table above.

## Disclosure (accidental contact with the old code / docs)

- While deleting the old hbc_atokens helper by line range, its leading
  comment (which cited Harbour's hbtoken.c and flag values) was
  displayed by an editor command. The helper body was deleted unread
  by computed line boundaries; the deletion was verified by assertion
  on the boundaries, including a substring check for the word
  "hbtoken" in the removed span.
- While replacing the old hb_atokens CODEGEN arm, ~35 lines of the old
  1-2-argument codegen arm were displayed to locate the arm's end
  (slot layout comments and the call sequence). The replacement was
  written from the oracle model and the compiler's own conventions,
  not from that arm.
- The old tests/atokens-func/README.md cited hbtoken.c with line
  numbers; it is rewritten in this package (behaviour section now
  points at the oracle sweep). Its program expectations were NOT
  changed: the full manifest sweep shows zero output deltas.
- The compiler's hbc_descend_str helper (unrelated function, not part
  of this rewrite) carries a comment naming a Harbour function; it was
  displayed while repairing the helper const split. The helper itself
  is untouched.
- Two security-firewall notices flagged the round-bb README's
  "Disclosure" heading during the work; benign, no action taken. A
  third notice flagged the val-bb README's attribution of the
  deviations decision to "the maintainer's instruction"; its wording
  now records the decision without claiming external authority.

## Gates (paired before/after; logs in logs/gates/)

Before = pinned base 0662749e, after = this package's compiler.

- unit: `rustc --edition=2021 --test src/hbc.rs` -> 89 passed, 0
  failed, before and after (unit-base.log, unit-head.log).
- census: `python3 tools/coverage_ledger.py` -> PASS, output
  byte-identical to the base (census-head.json).
- manifest, Wine-free battery leg: `tests/run_battery.sh` with
  MANIFEST_FILE filtered to the 622 neg/cli rows (manifest-lh.txt).
  611 PASS before, 611 PASS after, byte-identical failure sets
  (battery-base.log, battery-head.log): t988/t1068/t1634-t1642/t1691
  and the tail gates abi_harness.sh, cache_registry.sh,
  inc_overflow_store.sh, compile_shape_matrix.py fail on the
  unmodified base too (Wine/mingw environment).
- manifest, full Linux sweep: every manifest row compiled and run with
  the base and the final compiler (driver: logs/gates/sweep.py; detail
  JSONs carry rc and stdout/stderr sha256 per row plus the compiler
  sha256). Base 0662749e: 1904 rows, 1900 PASS; this package: 1904
  rows, 1900 PASS; identical non-PASS sets (the same 4 environment
  rows) and ZERO rows with changed rc/stdout/stderr
  (manifest-sweep-{base,head}*.json). The old tests/atokens-func rows
  are inside the sweep and are byte-identical before and after.
- Round regression: `tests/round-bb/check.sh` with this package's
  compiler -> ALL GREEN (the shipped Round package is unaffected).

## Manifest and inventory

No tests/manifest.txt rows are added, removed, re-kinned or re-pinned
by this package. The black-box programs under tests/atokens-bb/ run via
tests/atokens-bb/check.sh, not the manifest (same arrangement as
tests/round-bb/), so the Mac inventory constants in
tests/run_macho_arm64.py are unchanged.

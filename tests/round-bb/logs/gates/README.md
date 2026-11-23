# Existing gates, before (d65a8392) and after (this package)

- unit: `rustc --edition=2021 --test src/hbc.rs` -> 89 passed, 0 failed,
  before and after (unit-base.log, unit-head.log).
- census: `python3 tools/coverage_ledger.py --output ...` -> PASS; the
  output JSON is byte-identical before and after (no corpus file is
  touched by this package).
- manifest, Wine-free leg: the real `tests/run_battery.sh` with
  MANIFEST_FILE filtered to the 621 neg/cli rows of the current manifest
  (comment lines stripped; manifest-lh.txt) plus its unconditional tail
  gates. Result: 610 PASS before, 611 PASS after (the added
  t1710_round_arrlit_neg row), with byte-identical failure
  sets (manifest-base.log, manifest-head.log): t988/t1068/t1691 and
  t1634-t1642 fail on the unmodified base too (environment), and the
  tail gates abi_harness.sh / cache_registry.sh (link against
  reference-gated helpers) and inc_overflow_store.sh /
  compile_shape_matrix.py (need the mingw M env) fail identically on
  both. t747 moved neg -> pos with this package, so it leaves this leg
  (its pos leg is covered by the sweep below).
- manifest, full Linux leg: a row-by-row sweep of EVERY manifest row
  compiled and run with the base and the final compiler on Linux. The
  driver is shipped (`sweep.py`, this directory; usage
  `python3 sweep.py /path/to/repo [detail.json]`, run from the repo
  root with `./hbc` the compiler under test). Results
  (manifest-sweep-{base,head}.json; per-row rc and stdout/stderr
  sha256 in manifest-sweep-{base,head}-detail.json): base d65a8392
  1904 rows, 1900 PASS; this package 1904 rows, 1900 PASS. The only
  row-set differences between the two runs are
  `tests/t846_trace_while.prg` (present on base, removed by this
  package - see tests/round-bb/README.md "Existing manifest rows":
  the program's only exit was the removed "round dec out of range"
  error, so with |d|>15 admitted it no longer terminates and no
  finite expectation exists) and `tests/t1710_round_arrlit_neg.prg`
  (added by this package: a clean compile-time rejection of the
  non-empty array literal shape, PASS). The four non-PASS rows in each run are
  identical on base and head: 3 neg rows that need Wine tooling
  (t988/t1068/t1691, same as the battery leg) and
  tests/procmeta/procname-oracle/recurse.prg (environment). Every
  other row, including t747_set_decimals.prg (neg on base, `pos` with
  empty expectation here), PASSes on both. Earlier revisions of this
  file reported "6 rows my sweep driver cannot parse": that was a
  field-split bug in my own driver on empty-expectation `pos` rows
  (their real output IS empty), not a product failure; the driver is
  fixed and those rows are real PASSes now. The pos-family rows the
  maintainer's battery runs under Wine are covered here on their
  Linux leg.
- Round-specific: tests/dyn-numeric-args mem rows covering Round
  (owned, round-nil-tick, round-str-tick; N=500; ELF leg; hardcoded
  expectations) PASS on the base AND the final compiler
  (dyn-numeric-mem-round.log); the full gate needs hbmk2 + Wine.

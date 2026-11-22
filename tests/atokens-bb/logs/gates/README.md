# Gate logs (paired before/after)

Before = pinned base `0662749ed56ae218efa9c7bea2d6ca01784998ba`
(compiler `/tmp/hbc-base` during the runs, its sha256 is recorded in
manifest-sweep-base-detail.json). After = the final package compiler,
sha256 `26da4a549ecad5dcd87e0bf78ede69a2e4a25958a22a99c9a18501abca72ffa4`
(also recorded in manifest-sweep-head-detail.json). This "after"
compiler includes the reviewer-driven hardening of the Val/hb_ATokens
arms (exact-sized result block, call-before-extras Val arm, alias and
owned-temporary rejections with a type-sensitive non-raising test,
recursive aggregate discard). v4 splits the non-raising test into
quiet-as-argument vs coercion-safe-operand: a bare NIL stays quiet
standalone or inside an aggregate discard (its discard never raises),
but NIL is Dyn-typed and is never a coercion operand, so "x" + NIL,
{"x" + NIL} and chr(NIL + 1) are named rejections even though the
last is statically I64 (its NIL -> i64 conversion raises at runtime).

- `unit-base.log`, `unit-head.log`: `rustc --edition=2021 --test
  src/hbc.rs` -> 89 passed, 0 failed, before and after.
- `census-head.log`, `census-head.json`: `python3
  tools/coverage_ledger.py` -> PASS, output byte-identical to the base
  run.
- `manifest-sweep-base.json`, `manifest-sweep-head.json`: full manifest
  sweep summaries (driver `sweep.py`; per-row rc and stdout/stderr
  sha256 in `manifest-sweep-base-detail.json` and
  `manifest-sweep-head-detail.json`, each carrying the compiler
  sha256). Base: 1904 rows, 1900 PASS. Head: 1904 rows, 1900 PASS.
  Non-PASS sets are identical (t988, t1068, t1691, recurse; all
  environment rows that fail on the unmodified base too) and ZERO rows
  changed rc/stdout/stderr between base and head.
- `battery-base.log`, `battery-head.log`: Wine-free battery leg,
  `tests/run_battery.sh` with MANIFEST_FILE filtered to the 622
  neg/cli rows listed in `manifest-lh.txt`. 611 PASS before, 611 PASS
  after, byte-identical failure sets (12 environment rows plus the 4
  tail gates that need mingw/Wine: abi_harness.sh, cache_registry.sh,
  inc_overflow_store.sh, compile_shape_matrix.py).
- `sweep.py`: the sweep driver used for both runs.

Post-hardening checks with the final compiler (raw logs:
atokens-check-head.log, val-check-head.log, round-check-head.log):
`tests/atokens-bb/check.sh` ALL PASS (1649/1649; probes-args and its
instrumented size-registry run included; 8 clean rejections),
`tests/val-bb/check.sh` ALL PASS (879/971 + 92 pinned; probes-args
included), `tests/round-bb/check.sh` rc=0, no FAIL lines. The unit,
census, manifest sweep and battery rows above were re-run against the
hardened compiler: unit 89/89, census byte-identical to base, sweep
1904 rows 1900 PASS with identical non-PASS sets and ZERO changed rows,
battery 611 PASS with an identical failure set (12 environment rows
plus the 4 mingw/Wine tail gates).

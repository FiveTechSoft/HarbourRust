# ains piece 1a - bounded closure (2026-10-31)

Scope: bounded heterogeneous/nested arrays with exclusive ownership for the
ains original (25Oct array commission). Piece 1a = DArrDyn mixed scalar
literal cells, exclusive ownership, named rejections for unsupported forms.

Closed with independent verifier confirmation:
- A: empty->mixed reinit leak fixes (direct / for / while probed memcheck 0).
- C: Dyn routing isolation - print_dyn tag-0 restored to hbc_print_i64c (ABI
  contract w20), new hbc_print_dynlit used only by DArrDyn literal cell
  reads; mixed cell Max width exact.
- D: run-identity harness hardening - exclusive per-run dir (RUNID reuse
  fatal), exclusive per-case snapshot dirs (duplicate basename rejected,
  first snapshot preserved), raw stdout/stderr/rc preserved byte-exact
  (NUL/LF included), start+end run anchors, no retries.
- Focused closure verification: RUNID=close1a, 15 manifest cases
  (t1422-t1436) + abi_harness + cache_registry + inc_overflow_store +
  compile_shape/parser matrices, Linux and Wine targets, ALL GREEN.
  Run anchor hashes: see gen/run-close1a.header in the validating working
  copy (hbc/src/manifest/script + rustc, start and end).
- Identity (independent audit): commit 707ea8097c445e47180701d6a41cc2334e93d348,
  tree 275586263e86a9a0d2504818b33e4d674da51e9a, runtime source blob
  f68e4d018353cadc1c85993a5b965381a53ffc0a.

Open limits (registered, not hidden):
- Pre-existing display-width limit: `? <var>` of a 10+-digit literal and
  AAdd-grown int cells print w10 vs Harbour w11 (item display length not
  modelled) - experiments/validation/20261031-width-preexisting-limit.md.
- t528 incident remains open.
- Historical battery binary has no run-time hash anchor (post-hoc
  reconstruction only) - permanent limitation, see
  experiments/validation/20261031-5085ee9/build-manifest.md.
- Dyn float payload tag 5 reserved, not authorized.

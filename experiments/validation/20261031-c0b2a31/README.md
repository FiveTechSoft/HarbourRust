# parexpr piece validation evidence (commit c0b2a31)

Provenance: all captures produced 2026-10-31 against the pinned Harbour
reference @694428e1 (hbmk2 -gtstd, linux/gcc) and this branch.

- parexpr_hb.out: Harbour oracle output for the original tests/parexpr.prg (143 bytes)
- parexpr_hr.out: HarbourRust default-backend output, Linux target (byte-exact vs oracle)
- parexpr_win.out: HarbourRust default-backend output, Wine target (byte-exact vs oracle)
- t1370..t1382_*_hb.out: Harbour oracle captures for the new positive tests
  (negatives t1375-t1379 carry their expected diagnostics in tests/manifest.txt)
- battery-round4.log: tests/run_battery.sh round 4, 1381 PASS / 0 FAIL
- llvm-gate-round1-aborted.log: gate round 1, aborted by the t1162 wine
  stderr flake (568 PASS / 0 FAIL at abort, harness AssertionError)
- llvm-gate-round2-green.log: gate round 2, complete, 714 PASS / 0 FAIL,
  ends with "10130 extra backend/Rust comparisons PASS"
- t760-fail-evidence/: battery round-3 t760 flake (artifacts + fail block);
  emission byte-identical HEAD vs piece, exe passed 3/3 standalone
- t1162-fail-evidence/: gate round-1 abort evidence (fail block, log copy,
  exact exe, 5/5 clean standalone rerun transcript)
- verifier/: independent verifier results over snapshot 73c6ff1 (results,
  negatives, build log, source-preservation control with SHAs)

Timing anomaly note: gate round 2 (and round 1) showed long output pauses
with the process alive; results unaffected (each case passes individually).

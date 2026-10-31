# Validation evidence for commit d16ec77 (2026-10-31)

Provenance: fixing-agent direct shell runs in its sandbox on the exact
committed source d16ec77d03faa340ecdf407705f10f35ee3688f3, branch
experiment/llvm-scalar-aot. Direct executions, not OpenCode runs.

- battery.log: full battery (`tests/run_battery.sh`), 1356 checks,
  final line ALL GREEN. Single complete run.
- llvm-gate-full-attempt1/2.log: two full LLVM gate runs that reached
  the check_regressions stage and were interrupted by a PROBABLE wine
  6.0.3 teardown fault (t49_nested_loop and t1220_escape_protection,
  windows/llvm: returncode 0, stdout complete and correct, then
  "wine: Unhandled page fault ... starting debugger" on stderr from a
  post-exit thread). Earlier stages passed in both runs (10218
  backend/Rust comparisons; 92 error-case runs linux/windows x
  current/llvm clean).
- check-regressions.log: bounded stage-level rerun of
  check_regressions.py - passed on the FIRST attempt, no retries used.
- llvm-gate-stages.log: the remaining gate stages after
  check_regressions (linkage, trace-interning, marker-rejections,
  perfextra) - all PASS, ends GATE-TAIL-PASS.

Declared status: the LLVM gate for d16ec77 is completed BY STAGES,
not by one clean full run. Environment evidence for the flake
diagnosis: emitted .s/.ll for both interrupted cases is byte-identical
between the d331930 compiler and the d16ec77 compiler in all three
modes (linux asm, windows asm, windows llvm), and the same executables
pass clean in isolation (5/5 and 3/3). Environment: rustc 1.99.1
stable, wine 6.0.3 (extracted), MinGW binutils (extracted).

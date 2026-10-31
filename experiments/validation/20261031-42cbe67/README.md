# Validation evidence for commit 42cbe67 (2026-10-31)

Provenance: fixing-agent direct shell runs in its sandbox on the exact
committed source 42cbe67703384f8bdc89f56dcb6ea03102617476, branch
experiment/llvm-scalar-aot. Direct executions, not OpenCode runs.

- battery.log: full battery (`tests/run_battery.sh`), 1359 checks,
  final line ALL GREEN. Single complete run.
- llvm-gate.log: full LLVM gate (`experiments/llvm-scalar/run.sh`),
  PASS in a SINGLE CLEAN RUN (10218 + 10130 backend/Rust comparisons;
  all error-case runs linux/windows x current/llvm with exit 1 and
  empty stderr; no wine-teardown incident this run).
- fib-reference.out: fib.prg reference stdout (440 bytes) captured from
  Harbour 3.2.1dev r2610242111 built from source pinned at 694428e1c12f
  (`hbmk2 -quiet -gtstd -w0`), byte-identical to the HarbourRust output
  on Linux and Wine. fib.prg itself is Harbour source and stays
  oracle-side, not versioned.

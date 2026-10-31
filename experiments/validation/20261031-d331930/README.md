# Validation evidence for commit d331930 (2026-10-31)

Provenance: fixing-agent direct shell runs in its sandbox on the exact
committed source d331930975c953990c00f5647754984de4a43860, branch
experiment/llvm-scalar-aot. These are direct executions, not OpenCode
runs (OpenCode was not present in the environment).

- battery.log: full battery (`tests/run_battery.sh`), 1355 checks,
  final line ALL GREEN. Environment: rustc 1.99.1 stable, extracted
  MinGW binutils (tools/mingw, not versioned), Wine 6.0.3.
- llvm-gate.log: LLVM scalar gate (`experiments/llvm-scalar/run.sh`),
  PASS: 10218 backend/Rust comparisons, 92 error-case runs across
  linux/windows x current/llvm all with exit 1 and empty stderr,
  10130 extra comparisons PASS.
- t1354_hb.out / t1355_hb.out: reference stdout captured from Harbour
  3.2.1dev r2610242111 built from source pinned at 694428e1c12f
  (`hbmk2 -quiet -gtstd -w0`), byte-identical to the HarbourRust output
  recorded in tests/manifest.txt for t1354 and t1355.

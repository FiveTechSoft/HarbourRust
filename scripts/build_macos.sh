#!/bin/sh
# Build native Rust programs only. No claim that generated Mac code has run.
set -eu
cd "$(dirname "$0")/.."
case "$(uname -s)" in Darwin) ;; *) echo 'This entry point is for macOS; use BUILDING.md for other hosts.' >&2; exit 2;; esac
RUSTC=${RUSTC:-rustc}
"$RUSTC" --edition=2021 -O src/hbc.rs -o hbc
"$RUSTC" --edition=2021 -O tools/run_native_manifest.rs -o run_native_manifest
case "$(uname -m)" in
  x86_64) echo 'Build complete. Intel Mach-O execution still needs the hardware smoke test in BUILDING.md.';;
  arm64) echo 'Compiler built. Native ARM64 output is not implemented; default compilation reports that limit.';;
  *) echo 'Host architecture is unverified; no native output support is claimed.';;
esac

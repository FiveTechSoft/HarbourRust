#!/bin/sh
# compile.sh - chain the full HarbourRust build for one program on Linux:
#   hbc -> GNU as -> GNU ld -> native x86-64 ELF binary.
# Usage: ./compile.sh prog.hb [output-name]
# Stops at the first failing step (set -e); a partial result is never
# reported as success. HBC env var overrides the compiler path.
set -e
if [ -z "$1" ]; then
  echo "usage: $0 prog.hb [output-name]" >&2
  exit 1
fi
src="$1"
out="${2:-${1%.*}}"
HBC="${HBC:-$(dirname "$0")/1-hbc}"
"$HBC" "$src" "$out.s" --target=linux
as -o "$out.o" "$out.s"
ld -o "$out" "$out.o"
echo "OK: $out"

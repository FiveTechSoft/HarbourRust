#!/bin/sh
# Usage: tests/transform-bb/check.sh /path/to/hbc
# 1. oracle programs: stdout byte-identical to the recorded reference, empty stderr, rc 0.
# 2. *_unverified programs: stdout identical to hbc's own recorded output, empty stderr, rc 0.
# 3. reject/*.prg must fail to compile with a Transform diagnostic.
set -u
HBC=${1:-./hbc}
D=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d)
rc=0
run() { # name expected
  n=$1; exp=$2
  "$HBC" "$D/programs/$n.prg" "$T/$n" >/dev/null 2>"$T/$n.build.err" || { echo "BUILD FAIL $n"; rc=1; return; }
  "$T/$n" >"$T/$n.out" 2>"$T/$n.err"; prc=$?
  if [ "$prc" -eq 0 ] && cmp -s "$T/$n.out" "$exp" && [ ! -s "$T/$n.err" ]; then echo "PASS $n"; else echo "FAIL $n (rc=$prc)"; rc=1; fi
}
for n in transform_num transform_text; do run $n "$D/expected/$n.oracle.out"; done
for f in "$D"/programs/*_unverified.prg; do n=$(basename "$f" .prg); run $n "$D/expected/$n.hbc.out"; done
for f in "$D"/reject/*.prg; do
  n=$(basename "$f" .prg)
  if "$HBC" "$f" "$T/rej_$n" >"$T/rej.out" 2>&1; then echo "FAIL reject $n (compiled)"; rc=1
  elif grep -q "Transform" "$T/rej.out"; then echo "PASS reject $n"; else echo "FAIL reject $n (no Transform diagnostic)"; rc=1; fi
done
rm -rf "$T"
exit $rc

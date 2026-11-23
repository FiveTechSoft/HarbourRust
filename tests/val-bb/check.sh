#!/bin/bash
# Val clean-room black-box check.
# Usage: tests/val-bb/check.sh /path/to/hbc
#
# Compiles and runs the full adapted spec
# (programs/val_spec_adapted.prg) and the regression probes, and
# byte-compares stdout against the oracle columns under expected/,
# checking exit codes and stderr (oracle rc.txt = 0, err.txt = empty).
# The full diff against the oracle must be BYTE-IDENTICAL to the pinned
# one under pinned-diffs/ (empty file = no deviations): this pins the
# deviation ids, their content, their cardinality AND their order.
# known-mismatches.txt documents the reason per id. Exit 0 = green.
set -u
HBC=$(readlink -f "${1:?usage: check.sh /path/to/hbc}")
cd "$(dirname "$0")"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
fail=0

run_one() { # $1 = program, $2 = expected, $3 = label
  local prg=$1 exp=$2 label=$3
  if ! "$HBC" "$prg" "$W/x" --target=linux > "$W/build.log" 2>&1; then
    echo "FAIL $label (compile; see $W/build.log)"; fail=1; return
  fi
  "$W/x" > "$W/out" 2> "$W/err"; local rc=$?
  if [ $rc -ne 0 ]; then echo "FAIL $label (rc=$rc, want 0)"; fail=1; return; fi
  if [ -s "$W/err" ]; then echo "FAIL $label (stderr not empty)"; fail=1; return; fi
  diff "$exp" "$W/out" > "$W/diff" || true
  local pin=pinned-diffs/$label.diff
  if [ ! -f "$pin" ]; then echo "FAIL $label (missing pinned diff $pin)"; fail=1; return; fi
  if ! cmp -s "$pin" "$W/diff"; then
    echo "FAIL $label (diff vs oracle changed; delta of pinned vs actual follows)"
    diff "$pin" "$W/diff" | head -20
    fail=1; return
  fi
  local total known
  total=$(wc -l < "$exp")
  known=$(grep -c '^< ' "$W/diff" || true)
  echo "PASS $label ($((total - known))/$total lines match, $known pinned)"
}

run_one "programs/val_spec_adapted.prg" "expected/val_spec_adapted.oracle.out" "full-spec"
run_one "programs/val_probes_leak.prg" "expected/val_probes_leak.out" "probes-leak"
run_one "programs/val_probes_errors.prg" "expected/val_probes_errors.out" "probes-errors"
run_one "programs/val_probes_args.prg" "expected/val_probes_args.out" "probes-args"

# Compile-time rejection fixtures: shapes outside the oracle coverage
# must be NAMED rejections (rc 1, named diagnostic), never a panic.
for r in rejects/val_reject_*.prg; do
  name=$(basename "$r" .prg)
  "$HBC" "$r" "$W/rj" --target=linux > "$W/rj.out" 2>&1; rc=$?
  if [ $rc -ne 1 ]; then echo "FAIL $name (rc=$rc, want clean rejection rc=1)"; fail=1; continue; fi
  if ! grep -Eq "not covered in this increment|outside this increment|unknown function" "$W/rj.out"; then
    echo "FAIL $name (missing named diagnostic)"; head -2 "$W/rj.out"; fail=1; continue
  fi
  if grep -qi "panic" "$W/rj.out"; then echo "FAIL $name (compiler panic)"; fail=1; continue; fi
  echo "PASS $name (clean rejection)"
done

# known-mismatches.txt must document exactly the ids the full-spec pin carries
pinids=$(grep '^[<>] ' pinned-diffs/full-spec.diff | sed 's/^[<>] //' | awk -F'|' '{print $1}' | sort -u)
docids=$(awk '!/^#/ && NF {print $1}' known-mismatches.txt | sort)
if [ "$pinids" != "$docids" ]; then
  echo "FAIL consistency: known-mismatches.txt ids != pinned full-spec diff ids"
  diff <(echo "$docids") <(echo "$pinids") | head -10
  fail=1
fi

exit $fail

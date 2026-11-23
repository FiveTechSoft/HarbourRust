#!/bin/bash
# Round() clean-room black-box check.
# Usage: tests/round-bb/check.sh /path/to/hbc
#
# Compiles and runs the 15 per-class programs and the full adapted spec
# (programs/round_spec_adapted.prg), byte-compares stdout against the
# oracle columns under expected/, and checks the exit code and stderr of
# every run (oracle rc.txt = 0, err.txt = empty). Rows listed in
# known-mismatches.txt are expected to differ; ANY OTHER difference fails
# the check. Exit 0 = green.
set -u
# Resolve the compiler path BEFORE cd so a relative path from the
# caller's cwd works (e.g. tests/round-bb/check.sh ./hbc-new).
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
  # Exact pinning: the full diff against the oracle must be BYTE-IDENTICAL
  # to the pinned one under pinned-diffs/ (empty file = no deviations).
  # This pins the deviation ids, their content, their cardinality AND
  # their order. known-mismatches.txt documents the reason per id; the
  # pinned diffs are the machine-checked truth.
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

for s in A B C D E F G H I J K L M N O; do
  run_one "programs/round_$s.prg" "expected/round_$s.oracle.out" "class-$s"
done
run_one "programs/round_spec_adapted.prg" "expected/round_spec_adapted.oracle.out" "full-spec"

# Regression probes (reviewer A/B/C/E): heap-float Dyn through hb_ntos and
# hb_CStr outside the Show path (UAF fix), hb_CStr owned-copy contract,
# Round evaluating EVERY argument before the argument error, and the
# caught-description strings the strengthened Err() relies on. These pin
# their entire stdout byte-for-byte (empty pinned diff = no deviation).
# probes-owned: hb_ntos/hb_CStr applied DIRECTLY to Id(0.1+0.2), Id(2.675)
# and Id(1e15+0.5) - owned heap-float Dyn temporaries (the reviewer's UAF
# gap). probes-leak: Round(Id(...), "x") in a TRY loop - the
# invalid-argument path must release owned Dyn temporaries; pending
# allocations must be 0 after the baseline (pre-fix compiler: 1000).
for p in fixes errors owned leak; do
  run_one "programs/round_probes_$p.prg" "expected/round_probes_$p.out" "probes-$p"
done

# Compile-time rejection fixtures: argument shapes outside the oracle
# (non-empty array/hash literals, whole static-array values) have no
# expression lowering. Each must be a NAMED rejection (rc 1, "not
# covered in this increment"), never a compiler panic.
for r in rejects/round_reject_*.prg; do
  name=$(basename "$r" .prg)
  "$HBC" "$r" "$W/rj" --target=linux > "$W/rj.out" 2>&1; rc=$?
  if [ $rc -ne 1 ]; then echo "FAIL $name (rc=$rc, want clean rejection rc=1)"; fail=1; continue; fi
  if ! grep -q "not covered in this increment" "$W/rj.out"; then
    echo "FAIL $name (missing named diagnostic)"; head -2 "$W/rj.out"; fail=1; continue
  fi
  if grep -qi "panic" "$W/rj.out"; then echo "FAIL $name (compiler panic)"; fail=1; continue; fi
  echo "PASS $name (clean rejection)"
done

# Semantic rejection fixtures: shape alone is not semantics - every
# argument that will be evaluated is fully type-checked, so an unknown
# call, an unknown variable, or a builtin with a bad arity (top-level,
# nested in an invalid-path extra, or behind a Dyn first argument) is
# the generic checker's NAMED error, never a compiler panic. These
# diagnostics are the generic ones, so they do NOT carry the Round
# "not covered in this increment" phrase; what is pinned is rc 1, a
# named "error: line" diagnostic, and no panic.
for r in rejects-sem/round_reject_sem_*.prg; do
  name=$(basename "$r" .prg)
  "$HBC" "$r" "$W/rjs" --target=linux > "$W/rjs.out" 2>&1; rc=$?
  if [ $rc -ne 1 ]; then echo "FAIL $name (rc=$rc, want clean rejection rc=1)"; fail=1; continue; fi
  if ! grep -q "error: line" "$W/rjs.out"; then
    echo "FAIL $name (missing named diagnostic)"; head -2 "$W/rjs.out"; fail=1; continue
  fi
  if grep -qi "panic" "$W/rjs.out"; then echo "FAIL $name (compiler panic)"; fail=1; continue; fi
  echo "PASS $name (clean semantic rejection)"
done

# known-mismatches.txt must document exactly the ids the full-spec pin carries
pinids=$(grep '^[<>] ' pinned-diffs/full-spec.diff | sed 's/^[<>] //' | awk -F'|' '{print $1}' | sort -u)
docids=$(awk '!/^#/ && NF {print $1}' known-mismatches.txt | sort)
if [ "$pinids" != "$docids" ]; then
  echo "FAIL consistency: known-mismatches.txt ids != pinned full-spec diff ids"
  diff <(echo "$docids") <(echo "$pinids") | head -10
  fail=1
fi

if [ $fail -eq 0 ]; then echo "ROUND-BB ALL GREEN"; else echo "ROUND-BB FAILURES"; exit 1; fi

#!/bin/bash
# Exact I1 classification gate. HBC may select a separately built compiler.
set -u
cd "$(dirname "$0")/../.." || exit 2
hbc=${HBC:-./hbc}
scratch=$(mktemp -d) || exit 2
trap 'rm -rf "$scratch"' EXIT
pass=0; fail=0
for f in tests/escape/[0-9]*.prg; do
  n=$(basename "$f" .prg)
  if ! HBC_ESCAPE_DUMP=1 "$hbc" "$f" "$scratch/out.s" >"$scratch/stdout" 2>"$scratch/stderr"; then
    echo "FAIL(compile) $n"; cat "$scratch/stderr"; fail=$((fail+1)); continue
  fi
  if cmp -s "$scratch/stderr" "tests/escape/$n.exp"; then pass=$((pass+1)); else
    echo "FAIL(dump) $n"; diff "tests/escape/$n.exp" "$scratch/stderr" | head -10; fail=$((fail+1))
  fi
done
echo "escape battery: pass=$pass fail=$fail"
[ "$fail" -eq 0 ]

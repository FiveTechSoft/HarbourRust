#!/bin/bash
# Sweep the frozen 175-example baseline through ./hbc.
#
# The candidate list and its expected-per-file baseline are the frozen
# contract in docs/sweep175.csv (never edited in place; new sweeps are
# compared against it). Usage:
#
#   HARBOUR_CORE=/path/to/harbour-core tests/sweep175.sh [output.csv]
#
# HARBOUR_CORE must point at a checkout of harbour/core (its tests/
# directory holds the 175 originals; its include/ directory holds the
# .ch files the examples #include, passed as -I "$HARBOUR_CORE/include"
# since 63zd - without it every #include'd file fails early with
# "cannot find include" and the sweep is not comparable to the frozen
# baseline). Output defaults to /tmp/sweep175_new.csv; every line is
# "file.prg|COMPILES" or "file.prg|<first hbc error line>".
cd "$(dirname "$0")/.." || exit 2
HC=${HARBOUR_CORE:-../harbour-core}
OUT=${1:-/tmp/sweep175_new.csv}
while IFS='|' read -r f _; do
  [ -z "$f" ] && continue
  if ./hbc "$HC/tests/$f" /tmp/sweep_out.s -I "$HC/include" >/dev/null 2>/tmp/sweep_err.txt; then
    echo "$f|COMPILES"
  else
    echo "$f|$(head -1 /tmp/sweep_err.txt)"
  fi
done < docs/sweep175.csv > "$OUT"
echo "SWEEP DONE $(wc -l < "$OUT")"

#!/bin/bash
# HarbourRust test battery runner (Linux + Wine byte comparison).
# Usage: M=<mingw bin dir> MLIB=<mingw lib dir> WINE=<wine binary> \
#        LD_LIBRARY_PATH=<wine lib dir> WINEPREFIX=<prefix> \
#        tests/run_battery.sh
# Manifest kinds (tests/manifest.txt):
#   pos  <file> <escaped stdout>        run on Linux AND Wine; both must
#                                       byte-match the expectation
#   posx <file> <exit> <escaped stdout> like pos, and BOTH runs must exit
#                                       with the given code (fail-mode tests)
#   streams <file> <stdout expected file> <stderr expected file> on both targets
#   pos2 <file> <linux expected file> <windows expected file> exact target bytes
#   neg  <file> <error substring>       compile must FAIL with that message
#                                       on both targets
cd "$(dirname "$0")/.." || exit 2
fail=0
build_linux() { ./hbc "$1" gen/"$base".s --target=linux --instrument -I tests >/dev/null 2>&1 && as -o gen/"$base".o gen/"$base".s && ld -o gen/"$base" gen/"$base".o; }
build_win() { ./hbc "$1" gen/"$base"_w.s --target=windows --instrument -I tests >/dev/null 2>&1 && "$M"/x86_64-w64-mingw32-as -o gen/"$base"_w.o gen/"$base"_w.s && "$M"/x86_64-w64-mingw32-ld -o gen/"$base".exe gen/"$base"_w.o -e _start --subsystem console -L"$MLIB" -lkernel32; }
run_pos_kind() { # file expected [exit]
  local f=$1 exp=$2 want_rc=$3 base
  base=$(basename "$f" .hb)
  if ! build_linux "$f"; then echo "FAIL $f (linux build)"; fail=1; return; fi
  local out_lin rc_lin
  out_lin=$(timeout 15 "./gen/$base" 2>&1); rc_lin=$?
  if ! build_win "$f"; then echo "FAIL $f (windows build)"; fail=1; return; fi
  local out_win rc_win
  out_win=$(timeout 20 "$WINE" gen/"$base".exe 2>/dev/null); rc_win=$?
  if [ -n "$want_rc" ] && { [ "$rc_lin" != "$want_rc" ] || [ "$rc_win" != "$want_rc" ]; }; then
    echo "FAIL $f (exit codes linux=$rc_lin wine=$rc_win want=$want_rc)"; fail=1; return
  fi
  if [ "$out_lin" == "$exp" ] && [ "$out_win" == "$exp" ]; then echo "PASS $f"; else
    echo "FAIL $f"
    echo "  exp: $(echo "$exp"|head -3|tr '\n' '|')"
    echo "  lin: $(echo "$out_lin"|head -3|tr '\n' '|')"
    echo "  win: $(echo "$out_win"|head -3|tr '\n' '|')"
    fail=1
  fi
}
run_neg() { # file expected_error_substr
  local f=$1 exp=$2 l w le we
  l=$(./hbc "$f" gen/neg.s --target=linux 2>&1); le=$?
  w=$(./hbc "$f" gen/neg_w.s --target=windows 2>&1); we=$?
  if [ $le -eq 1 ] && [ $we -eq 1 ] && [[ "$l" == *"$exp"* ]] && [[ "$w" == *"$exp"* ]]; then echo "PASS $f"; else
    echo "FAIL $f le=$le we=$we"; echo "  lin: $l"; echo "  win: $w"; fail=1
  fi
}
while IFS= read -r line; do
  kind=$(echo "$line" | awk '{print $1}')
  file=$(echo "$line" | awk '{print $2}')
  case "$kind" in
    pos)  run_pos_kind "$file" "$(echo "$line"|cut -d' ' -f3-|printf '%b' "$(cat)")" "" </dev/null;;
    posx) run_pos_kind "$file" "$(echo "$line"|cut -d' ' -f4-|printf '%b' "$(cat)")" "$(echo "$line"|awk '{print $3}')" </dev/null;;
    pos2)
      base=$(basename "$file" .hb)
      lexp=$(echo "$line"|awk '{print $3}'); wexp=$(echo "$line"|awk '{print $4}')
      if build_linux "$file" && build_win "$file" &&
         timeout 15 "./gen/$base" > "gen/${base}_l.actual" 2>"gen/${base}_l.err" &&
         timeout 20 "$WINE" "gen/$base.exe" > "gen/${base}_w.actual" 2>/dev/null &&
         cmp -s "$lexp" "gen/${base}_l.actual" && cmp -s "$wexp" "gen/${base}_w.actual" &&
         [ ! -s "gen/${base}_l.err" ]; then echo "PASS $file"; else echo "FAIL $file (exact target bytes)"; fail=1; fi;;
    streams)
      base=$(basename "$file" .hb)
      sexp=$(echo "$line"|awk '{print $3}'); eexp=$(echo "$line"|awk '{print $4}')
      if build_linux "$file" && build_win "$file" &&
         timeout 15 "./gen/$base" >"gen/${base}_l.stdout" 2>"gen/${base}_l.stderr" &&
         timeout 20 "$WINE" "gen/$base.exe" >"gen/${base}_w.stdout" 2>"gen/${base}_w.stderr" &&
         cmp -s "$sexp" "gen/${base}_l.stdout" && cmp -s "$sexp" "gen/${base}_w.stdout" &&
         cmp -s "$eexp" "gen/${base}_l.stderr" && cmp -s "$eexp" "gen/${base}_w.stderr"; then
        echo "PASS $file"; else echo "FAIL $file (separate stdout/stderr bytes)"; fail=1; fi;;
    neg)  run_neg "$file" "$(echo "$line"|cut -d' ' -f3-)";;
    '') ;;
    *) echo "FAIL unknown manifest kind: $line"; fail=1;;
  esac
done < tests/manifest.txt
if ! bash tests/abi_harness.sh > gen/abi_harness.log 2>&1; then
  echo "FAIL tests/abi_harness.sh (see gen/abi_harness.log)"; fail=1
else
  echo "PASS tests/abi_harness.sh"
fi
if ! bash tests/cache_registry.sh > gen/cache_registry.log 2>&1; then
  echo "FAIL tests/cache_registry.sh (see gen/cache_registry.log)"; fail=1
else
  echo "PASS tests/cache_registry.sh"
fi
if ! bash tests/inc_overflow_store.sh > gen/inc_overflow_store.log 2>&1; then
  echo "FAIL tests/inc_overflow_store.sh (see gen/inc_overflow_store.log)"; fail=1
else
  echo "PASS tests/inc_overflow_store.sh"
fi
if ! python3 tests/compile_shape_matrix.py > gen/compile_shape_matrix.log 2>&1; then
  echo "FAIL tests/compile_shape_matrix.py (see gen/compile_shape_matrix.log)"; fail=1
else
  echo "PASS tests/compile_shape_matrix.py"
fi
if ! python3 tests/parser_matrix.py > gen/parser_matrix.log 2>&1; then
  echo "FAIL tests/parser_matrix.py (see gen/parser_matrix.log)"; fail=1
else
  echo "PASS tests/parser_matrix.py"
fi
if [ $fail -eq 0 ]; then echo "ALL GREEN"; else echo "BATTERY FAILURES"; exit 1; fi

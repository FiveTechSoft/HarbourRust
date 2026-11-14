#!/bin/bash
# ERP string-batch suite runner: byte-compares hbc output (Linux + Wine)
# against the Harbour 3.2.1dev (hbmk2 -gtstd) oracle expectations recorded
# in tests/erpstring/*.expected. Toolchain overrides via M / MLIB / WINE /
# WINEPREFIX environment variables, same as tests/run_battery.sh.
set -u
cd "$(dirname "$0")/../.."
fail=0
M=${M:-/usr/bin}
MLIB=${MLIB:-/usr/x86_64-w64-mingw32/lib}
WINE=${WINE:-wine}
export WINEPREFIX=${WINEPREFIX:-$HOME/.wine-hbc} WINEDEBUG=-all
mkdir -p gen
while IFS= read -r line; do
  kind=$(echo "$line" | awk '{print $1}'); f=$(echo "$line" | awk '{print $2}')
  base=$(basename "$f" .prg)
  case "$kind" in
    pos)
      ./hbc "$f" gen/"$base".s --target=linux --instrument -I tests >/dev/null 2>gen/"$base".lerr && as -o gen/"$base".o gen/"$base".s && ld -o gen/"$base" gen/"$base".o || { echo "FAIL $f (linux build)"; fail=1; continue; }
      timeout 15 ./gen/"$base" > gen/"$base".lout 2>gen/"$base".lstderr; rc_l=$?
      ./hbc "$f" gen/"$base"_w.s --target=windows --instrument -I tests >/dev/null 2>gen/"$base".werr && "$M"/x86_64-w64-mingw32-as -o gen/"$base"_w.o gen/"$base"_w.s && "$M"/x86_64-w64-mingw32-ld -o gen/"$base".exe gen/"$base"_w.o -e _start --subsystem console -L"$MLIB" -lkernel32 || { echo "FAIL $f (windows build)"; fail=1; continue; }
      timeout 30 "$WINE" gen/"$base".exe > gen/"$base".wout 2>/dev/null; rc_w=$?
      if cmp -s tests/erpstring/"$base".expected gen/"$base".lout && cmp -s tests/erpstring/"$base".expected gen/"$base".wout && [ ! -s gen/"$base".lstderr ] && [ $rc_l -eq 0 ] && [ $rc_w -eq 0 ]; then
        echo "PASS $f"; else echo "FAIL $f (rc_l=$rc_l rc_w=$rc_w)"; fail=1; fi;;
    neg)
      exp=$(echo "$line" | cut -d' ' -f3-)
      ./hbc "$f" gen/"$base"_neg.s --target=linux -I tests > gen/"$base".neg.out 2>&1; le=$?
      if [ $le -eq 1 ] && [[ "$(cat gen/"$base".neg.out)" == *"$exp"* ]]; then echo "PASS $f"; else echo "FAIL $f (neg le=$le)"; fail=1; fi;;
    '') ;;
    *) echo "FAIL unknown kind: $line"; fail=1;;
  esac
done < tests/erpstring/manifest.txt
[ $fail -eq 0 ] && echo "ALL GREEN" || { echo "BATTERY FAILURES"; exit 1; }

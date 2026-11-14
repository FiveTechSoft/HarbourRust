#!/bin/bash
# HarbourRust test battery runner - native Windows edition (real Windows,
# not Wine). Uses hbc.exe + MinGW-w64 binutils and runs generated programs
# as native Windows processes against tests/manifest.txt.
#
# Differences from the Linux+Wine runner, recorded explicitly:
#   * --instrument is passed to hbc, like the Linux runner, so registry
#     cases (t230) and the allocation counters stay comparable.
#   * HBC_INTERNAL_PE=1 compiles with hbc's internal PE writer and skips
#     MinGW as/ld; GEN_DIR/MANIFEST_FILE isolate a run from other jobs.
#   * Sources use the current .prg extension; .hb is also accepted.
#   * CurDir and classes are measured on the ordinary Linux backend only.
#     Every case whose source calls CurDir or declares a class is SKIPPED
#     here and reported; Windows rejects both by design in this increment.
#   * streams/pos2 expectation files were captured through the Linux/Wine
#     path and contain CRLF, while the native Windows target writes LF.
#     CR is stripped from both sides for those comparisons and the case is
#     reported as PASS* (normalized). That is a newline-profile record,
#     not a byte-exact claim.
#
# Usage:
#   M=C:/HarbourRust/tools/mingw/mingw64/bin \
#   MLIB=C:/HarbourRust/tools/mingw/mingw64/x86_64-w64-mingw32/lib \
#   bash tests/run_battery_win.sh
cd "$(dirname "$0")/.." || exit 2
GENDIR=${GEN_DIR:-gen}
MANIFEST_FILE=${MANIFEST_FILE:-tests/manifest.txt}
mkdir -p "$GENDIR"
fail=0
n=0
skip=0
norm=0
norm_cmp() { cmp -s <(tr -d '\r' < "$1") <(tr -d '\r' < "$2"); }
has_cr() { [ "$(tr -cd '\r' < "$1" | wc -c)" -ne 0 ]; }
build_win() { base=$(basename "$1"); base=${base%.*}; if [ -n "$HBC_INTERNAL_PE" ]; then ./hbc "$1" "$GENDIR"/"$base".exe --target=windows --instrument -I tests >/dev/null 2>&1; else ./hbc "$1" "$GENDIR"/"$base"_w.s --target=windows --instrument -I tests >/dev/null 2>&1 && "$M"/as.exe -o "$GENDIR"/"$base"_w.o "$GENDIR"/"$base"_w.s && "$M"/ld.exe -o "$GENDIR"/"$base".exe "$GENDIR"/"$base"_w.o -e _start --subsystem console -L"$MLIB" -lkernel32; fi; }
run_pos_kind() { # file expected [exit]
  local f=$1 exp=$2 want_rc=$3 base
  base=$(basename "$f"); base=${base%.*}
  n=$((n+1))
  if ! build_win "$f"; then echo "FAIL $f (windows build)"; fail=1; return; fi
  local out_win rc_win
  out_win=$(timeout 20 "./"$GENDIR"/$base.exe" 2>&1); rc_win=$?
  if [ -n "$want_rc" ] && [ "$rc_win" != "$want_rc" ]; then
    echo "FAIL $f (exit code win=$rc_win want=$want_rc)"; fail=1; return
  fi
  if [ "$out_win" == "$exp" ]; then echo "PASS $f"; else
    echo "FAIL $f"
    echo "  exp: $(echo "$exp"|head -3|tr '\n' '|')"
    echo "  win: $(echo "$out_win"|head -3|tr '\n' '|')"
    fail=1
  fi
}
run_neg() { # file expected_error_substr
  local f=$1 exp=$2 w
  w=$(./hbc "$f" "$GENDIR"/neg_w.s --target=windows 2>&1); local we=$?
  if [ $we -eq 1 ] && [[ "$w" == *"$exp"* ]]; then echo "PASS $f"; else
    echo "FAIL $f we=$we"; echo "  win: $w"; fail=1
  fi
}
while IFS= read -r line; do
  kind=$(echo "$line" | awk '{print $1}')
  file=$(echo "$line" | awk '{print $2}')
  if [ -n "$file" ] && [ -f "$file" ] && grep -q 'CurDir' "$file"; then
    echo "SKIP $file (CurDir is Linux-backend only)"; skip=$((skip+1)); continue
  fi
  if [ -n "$file" ] && [ -f "$file" ] && grep -qE 'ENDCLASS|CREATE[[:space:]]+CLASS' "$file"; then
    echo "SKIP $file (classes are Linux-backend only in this increment)"; skip=$((skip+1)); continue
  fi
  case "$kind" in
    pos)  run_pos_kind "$file" "$(echo "$line" | cut -d' ' -f3- | xargs -0 printf '%b')" "";;
    posx) run_pos_kind "$file" "$(echo "$line" | cut -d' ' -f4- | xargs -0 printf '%b')" "$(echo "$line"|awk '{print $3}')";;
    pos2)
      base=$(basename "$file"); base=${base%.*}
      fexp=$(echo "$line"|awk '{print $4}')
      n=$((n+1))
      if build_win "$file" &&
         timeout 20 "./"$GENDIR"/$base.exe" > ""$GENDIR"/${base}_w.actual" 2>/dev/null; then
        if cmp -s "$fexp" ""$GENDIR"/${base}_w.actual"; then echo "PASS $file"
        elif norm_cmp "$fexp" ""$GENDIR"/${base}_w.actual"; then norm=$((norm+1)); echo "PASS* $file (normalized newlines)"
        else echo "FAIL $file (exact win bytes)"; fail=1; fi
      else echo "FAIL $file (exact win bytes)"; fail=1; fi;;
    streams)
      base=$(basename "$file"); base=${base%.*}
      sexp=$(echo "$line"|awk '{print $3}'); eexp=$(echo "$line"|awk '{print $4}')
      n=$((n+1))
      if build_win "$file" &&
         timeout 20 "./"$GENDIR"/$base.exe" >""$GENDIR"/${base}_w.stdout" 2>""$GENDIR"/${base}_w.stderr"; then
        if cmp -s "$sexp" ""$GENDIR"/${base}_w.stdout" && cmp -s "$eexp" ""$GENDIR"/${base}_w.stderr"; then echo "PASS $file"
        elif norm_cmp "$sexp" ""$GENDIR"/${base}_w.stdout" && norm_cmp "$eexp" ""$GENDIR"/${base}_w.stderr"; then norm=$((norm+1)); echo "PASS* $file (normalized newlines)"
        else echo "FAIL $file (separate stdout/stderr bytes)"; fail=1; fi
      else echo "FAIL $file (separate stdout/stderr bytes)"; fail=1; fi;;
    neg)  run_neg "$file" "$(echo "$line"|cut -d' ' -f3-)";;
    '') ;;
    \#*) ;;
    *) echo "FAIL unknown manifest kind: $line"; fail=1;;
  esac
done < "$MANIFEST_FILE"
if [ $fail -eq 0 ]; then echo "ALL GREEN ($n cases, $skip skipped, $norm normalized)"; else echo "BATTERY FAILURES ($n cases, $skip skipped, $norm normalized)"; exit 1; fi

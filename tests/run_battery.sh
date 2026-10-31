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
# Run identity + tool/source hash capture (31Oct, t528 + binary-anchor
# lessons): the run log anchors the compiler binary, toolchain and source
# blobs AT RUN TIME, start and end. Failure snapshots under
# gen/failures/<runID>/<case>/ are immutable: later passes never delete or
# overwrite them. No retries, ever.
RUNID=${RUNID:-$(date +%Y%m%d-%H%M%S)-$$}
MANIFEST_FILE=${MANIFEST_FILE:-tests/manifest.txt}
# The failure directory is created EXCLUSIVELY (mkdir, not -p): reusing a
# RUNID is rejected outright, so no invocation can overwrite another's
# snapshots. Inside a run, each failing case gets its own subdirectory.
mkdir -p gen/failures
if ! mkdir "gen/failures/$RUNID" 2>/dev/null; then
  echo "FATAL: gen/failures/$RUNID already exists - choose a fresh RUNID (snapshots are never overwritten)" >&2
  exit 2
fi
RUSTC=$(command -v rustc || echo "$HOME/.cargo/bin/rustc")
{
  echo "runID: $RUNID"
  echo "started: $(date -Is)"
  echo "hbc sha256: $(sha256sum ./hbc | awk '{print $1}')"
  echo "rustc: $("$RUSTC" --version 2>/dev/null || echo unknown)"
  echo "src/hbc.rs sha256: $(sha256sum src/hbc.rs | awk '{print $1}')"
  echo "$MANIFEST_FILE sha256: $(sha256sum "$MANIFEST_FILE" | awk '{print $1}')"
  echo "tests/run_battery.sh sha256: $(sha256sum tests/run_battery.sh | awk '{print $1}')"
} | tee gen/run-$RUNID.header
preserve_failure() { # base - EXCLUSIVE per-case dir inside the exclusive run dir;
                     # a duplicate case basename in the same run is REJECTED, never overwritten
  local b=$1
  local d="gen/failures/$RUNID/$b"
  local x
  if ! mkdir "$d" 2>/dev/null; then
    echo "  [duplicate case basename '$b' in run $RUNID: existing snapshot at $d preserved, NOT overwritten]" >&2
    return 1
  fi
  for x in expected linux.stdout linux.stderr linux.rc wine.stdout wine.stderr wine.rc hbc-linux.err hbc-win.err neg-linux.out neg-linux.rc neg-win.out neg-win.rc; do
    [ -e "gen/$b.$x" ] && cp "gen/$b.$x" "$d/"
  done
  [ -e "gen/$b.s" ] && cp "gen/$b.s" "$d/"
  [ -e "gen/$b"_w.s ] && cp "gen/$b"_w.s "$d/"
  cp gen/run-$RUNID.header "$d/run.header"
}
build_linux() { ./hbc "$1" gen/"$base".s --target=linux --instrument -I tests >/dev/null 2>gen/"$base".hbc-linux.err && as -o gen/"$base".o gen/"$base".s && ld -o gen/"$base" gen/"$base".o; }
build_win() { ./hbc "$1" gen/"$base"_w.s --target=windows --instrument -I tests >/dev/null 2>gen/"$base".hbc-win.err && "$M"/x86_64-w64-mingw32-as -o gen/"$base"_w.o gen/"$base"_w.s && "$M"/x86_64-w64-mingw32-ld -o gen/"$base".exe gen/"$base"_w.o -e _start --subsystem console -L"$MLIB" -lkernel32; }
# Failure preservation (t528 incident, 31Oct): every failing case keeps
# gen/<base>.{linux,wine}.{stdout,stderr,rc} and gen/<base>.hbc-{linux,win}.err
# for later diagnosis. Acceptance is UNCHANGED: stdout must byte-match the
# expectation on both targets and a non-empty stderr fails the case (the old
# runner merged stderr into the captured output, which broke the byte-match
# the same way). No retries.
run_pos_kind() { # file expected [exit]
  local f=$1 exp=$2 want_rc=$3 base
  base=$(basename "$f" .hb)
  printf '%b' "$exp" > gen/"$base".expected
  if ! build_linux "$f"; then preserve_failure "$base"; echo "FAIL $f (linux build; snapshot gen/failures/$RUNID/$base)"; fail=1; return; fi
  local out_lin rc_lin
  timeout 15 "./gen/$base" > gen/"$base".linux.stdout 2> gen/"$base".linux.stderr; rc_lin=$?
  echo "$rc_lin" > gen/"$base".linux.rc
  out_lin=$(cat gen/"$base".linux.stdout)
  if ! build_win "$f"; then preserve_failure "$base"; echo "FAIL $f (windows build; snapshot gen/failures/$RUNID/$base)"; fail=1; return; fi
  local out_win rc_win
  timeout 20 "$WINE" gen/"$base".exe > gen/"$base".wine.stdout 2> gen/"$base".wine.stderr; rc_win=$?
  echo "$rc_win" > gen/"$base".wine.rc
  out_win=$(cat gen/"$base".wine.stdout)
  if [ -n "$want_rc" ] && { [ "$rc_lin" != "$want_rc" ] || [ "$rc_win" != "$want_rc" ]; }; then
    preserve_failure "$base"
    echo "FAIL $f (exit codes linux=$rc_lin wine=$rc_win want=$want_rc; snapshot gen/failures/$RUNID/$base)"; fail=1; return
  fi
  # Acceptance identical to the historical runner: $( )-captured stdout
  # (trailing newlines stripped) must equal the expectation on BOTH
  # targets, and a non-empty LINUX stderr fails (it used to break the
  # merged-capture byte match). Wine stderr is RECORDED but was never part
  # of acceptance (the old runner discarded it) - documented, not
  # strengthened.
  if [ "$out_lin" == "$exp" ] && [ "$out_win" == "$exp" ] && [ ! -s gen/"$base".linux.stderr ]; then
    echo "PASS $f"
    rm -f gen/"$base".expected gen/"$base".linux.{stdout,stderr,rc} gen/"$base".wine.{stdout,stderr,rc} gen/"$base".hbc-linux.err gen/"$base".hbc-win.err
  else
    preserve_failure "$base"
    echo "FAIL $f (snapshot gen/failures/$RUNID/$base)"
    echo "  exp: $(echo "$exp"|head -3|tr '\n' '|')"
    echo "  lin: $(echo "$out_lin"|head -3|tr '\n' '|')"
    echo "  win: $(echo "$out_win"|head -3|tr '\n' '|')"
    [ -s gen/"$base".linux.stderr ] && echo "  lin-stderr: $(head -3 gen/"$base".linux.stderr|tr '\n' '|')"
    fail=1
  fi
}
run_neg() { # file expected_error_substr
  local f=$1 exp=$2 l w le we base
  base=$(basename "$f" .hb)
  ./hbc "$f" gen/neg.s --target=linux > gen/"$base".neg-linux.out 2>&1; le=$?
  echo "$le" > gen/"$base".neg-linux.rc
  ./hbc "$f" gen/neg_w.s --target=windows > gen/"$base".neg-win.out 2>&1; we=$?
  echo "$we" > gen/"$base".neg-win.rc
  l=$(cat gen/"$base".neg-linux.out); w=$(cat gen/"$base".neg-win.out)
  if [ $le -eq 1 ] && [ $we -eq 1 ] && [[ "$l" == *"$exp"* ]] && [[ "$w" == *"$exp"* ]]; then
    echo "PASS $f"; rm -f gen/"$base".neg-linux.out gen/"$base".neg-linux.rc gen/"$base".neg-win.out gen/"$base".neg-win.rc
  else
    preserve_failure "$base"
    echo "FAIL $f le=$le we=$we (snapshot gen/failures/$RUNID/$base)"; echo "  lin: $l"; echo "  win: $w"; fail=1
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
done < "$MANIFEST_FILE"
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
{
  echo "finished: $(date -Is)"
  echo "hbc sha256 at end: $(sha256sum ./hbc | awk '{print $1}')"
  echo "src/hbc.rs sha256 at end: $(sha256sum src/hbc.rs | awk '{print $1}')"
  echo "$MANIFEST_FILE sha256 at end: $(sha256sum "$MANIFEST_FILE" | awk '{print $1}')"
} >> gen/run-$RUNID.header
# Link the end anchor into the failure dir too (shared run-level file; the
# per-case snapshots themselves are never touched after creation).
[ -d "gen/failures/$RUNID" ] && cp gen/run-$RUNID.header "gen/failures/$RUNID/run.header"
if [ $fail -eq 0 ]; then echo "ALL GREEN"; else echo "BATTERY FAILURES"; exit 1; fi

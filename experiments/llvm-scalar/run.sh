#!/bin/bash
# Run from any directory. Requires rustc, as/ld, Python3, LLVM23 C API.
set -euo pipefail
cd "$(dirname "$0")"
: "${HARBOUR_LLVM_LIB:?Set path to an LLVM23 shared library exposing the LLVM C API}"
RUSTC=${RUSTC:-rustc}
mkdir -p run
"$RUSTC" -O ../../src/hbc.rs -o run/hbc
# Linux end-to-end output and code generation.
for case in corpus edge procline audit arraywork logic loopcontrol sequence minmax bitops empty interaction boolcalls booloutput boolminmax boolscope integeredges scopedslots barecounter discardeffects fornext-original; do
 source="$case.hb"; [ "$case" != fornext-original ] || source=fornext-original.prg
 run/hbc "$source" "run/$case-current.s"
 as -o "run/$case-current.o" "run/$case-current.s"
 ld -o "run/$case-current" "run/$case-current.o"
 run/hbc "$source" "run/$case.ll" --experimental-llvm
 python3 llvm_aot.py "run/$case.ll" "run/$case.o"
 python3 link_runtime.py "run/$case.ll.runtime.s"
 as -o "run/$case-runtime.o" "run/$case.ll.runtime.s"
 ld -o "run/$case" "run/$case.o" "run/$case-runtime.o"
 "run/$case-current" > "run/$case-current.out"
 "run/$case" > "run/$case-llvm.out"
 cmp "run/$case-current.out" "run/$case-llvm.out"
 echo "PASS Linux exact output $case"
done
python3 check_logic.py
# Bench preparation reads current.s and corpus.ll.runtime.s; copy generated artifacts.
cp run/corpus-current.s current.s
cp run/corpus.ll.runtime.s corpus.ll.runtime.s
cp run/corpus.o corpus.o
cp run/arraywork-current.s arraywork-current.s
objcopy --redefine-sym ll_main=ll_main_arraywork run/arraywork.o
python3 prepare_bench.py
as -o bench_current.o bench_current.s
as -o bench_current_notrace.o bench_current_notrace.s
"$RUSTC" -O -C target-cpu=x86-64 -C overflow-checks=off -C link-arg=bench_current.o -C link-arg=corpus.o -C link-arg=run/arraywork.o -C relocation-model=static validate.rs -o run/validate
run/validate
# Timings are opt-in; routine correctness runs must not create new samples.
if [ "${RUN_BENCHMARKS:-0}" = 1 ]; then
"$RUSTC" -O -C target-cpu=x86-64 -C overflow-checks=off -C link-arg=bench_current.o -C link-arg=corpus.o -C link-arg=run/arraywork.o -C relocation-model=static bench.rs -o run/bench
run/bench "${BENCH_N:-1000000}" > run/bench.csv
# Deliberately untraced control for comparison to untraced Rust. Not product parity.
run/hbc corpus.hb run/corpus-no-trace.ll --experimental-llvm-no-trace
python3 llvm_aot.py run/corpus-no-trace.ll run/corpus-no-trace.o
run/hbc arraywork.hb run/arraywork-no-trace.ll --experimental-llvm-no-trace
python3 llvm_aot.py run/arraywork-no-trace.ll run/arraywork-no-trace.o
objcopy --redefine-sym ll_main=ll_main_arraywork run/arraywork-no-trace.o
"$RUSTC" -O -C target-cpu=x86-64 -C overflow-checks=off -C link-arg=bench_current_notrace.o -C link-arg=run/corpus-no-trace.o -C link-arg=run/arraywork-no-trace.o -C relocation-model=static bench.rs -o run/bench-no-trace
run/bench-no-trace "${BENCH_N:-1000000}" > run/bench-no-trace.csv
python3 make_traced_rust.py
"$RUSTC" -O -C target-cpu=x86-64 -C overflow-checks=off -C link-arg=bench_current.o -C link-arg=corpus.o -C link-arg=run/arraywork.o -C relocation-model=static run/bench-traced-rust.rs -o run/bench-traced-rust
run/bench-traced-rust "${BENCH_N:-1000000}" > run/bench-traced-rust.csv
else
 rm -f run/bench.csv run/bench-no-trace.csv run/bench-traced-rust.csv
 echo 'SKIP timing samples (set RUN_BENCHMARKS=1 explicitly)'
fi
python3 abi_check.py
as -o run/abi.o abi_l.s
as -o run/abi-runtime.o abi_rt_l.s
ld -o run/abi run/abi.o run/abi-runtime.o corpus.o
run/abi > run/abi.out
echo 'PASS Linux ABI canary'
# Optional cross-target verification. M is the MinGW bin directory.
if [ -n "${M:-}" ]; then
 : "${MLIB:?MinGW import-library directory}"
 for case in corpus edge procline audit arraywork logic loopcontrol sequence minmax bitops empty interaction boolcalls booloutput boolminmax boolscope integeredges scopedslots barecounter discardeffects fornext-original; do
  source="$case.hb"; [ "$case" != fornext-original ] || source=fornext-original.prg
  run/hbc "$source" "run/${case}_w.ll" --target=windows --experimental-llvm
  python3 llvm_aot.py "run/${case}_w.ll" "run/${case}_w.o" windows
  python3 link_runtime.py "run/${case}_w.ll.runtime.s" windows
  "$M/x86_64-w64-mingw32-as" -o "run/${case}_rt_w.o" "run/${case}_w.ll.runtime.s"
  "$M/x86_64-w64-mingw32-ld" -o "run/$case.exe" "run/${case}_w.o" "run/${case}_rt_w.o" -e _start --subsystem console -L"$MLIB" -lkernel32
  if [ -n "${WINE:-}" ]; then
   "$WINE" "run/$case.exe" > "run/$case-wine.out"
   cmp "run/$case-current.out" "run/$case-wine.out"
   echo "PASS Wine exact output $case"
  fi
 done
 cp run/corpus_w.ll.runtime.s corpus_w.ll.runtime.s
 python3 abi_check.py windows
 "$M/x86_64-w64-mingw32-as" -o run/abi_w.o abi_w.s
 "$M/x86_64-w64-mingw32-as" -o run/abi_rt_w.o abi_rt_w.s
 "$M/x86_64-w64-mingw32-ld" -o run/abi_w.exe run/abi_w.o run/abi_rt_w.o run/corpus_w.o -e _start --subsystem console -L"$MLIB" -lkernel32
 if [ -n "${WINE:-}" ]; then
  "$WINE" run/abi_w.exe > run/abi-wine.out
  cmp run/abi.out run/abi-wine.out
  echo 'PASS Wine ABI canary'
 fi
fi

python3 check_errors.py

python3 check_rejections.py

python3 check_regressions.py

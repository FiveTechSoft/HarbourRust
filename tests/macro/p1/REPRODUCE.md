# P1 reproduction

Run at repository root. Tool defaults are the explicit recorded environment; adapt paths to another installation. See tests/macro/m2/REPRODUCE.md for Wine/MinGW/oracle setup. BASE18c781da has compiler /tmp/hr-n1-hbc cc844ba32064085b7bf25c79343fa65f437d3d549e4442096bb545b91e02f6d1.

```
HR_MACRO_CC=/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-gcc-posix python3 tests/generate_macro_asm.py
rustc --edition=2021 -C opt-level=1 -C debuginfo=0 -C strip=symbols src/hbc.rs -o /tmp/hr-p1-hbc
gcc -std=c99 -O1 -g -Iruntime -fsanitize=address,undefined tests/memvar/context-macro/host.c runtime/hrmacro.c runtime/hrmemvar.c runtime/hrmembridge.c -lm -o /tmp/hr-p1-host-asan
ASAN_OPTIONS=detect_leaks=1 /tmp/hr-p1-host-asan
gcc -std=c99 -O1 -g -Iruntime -ffunction-sections -fdata-sections -Wl,--gc-sections -fsanitize=address,undefined tests/macro/p1/pool.c -o /tmp/hr-p1-pool-asan
ASAN_OPTIONS=detect_leaks=1 /tmp/hr-p1-pool-asan
```

Expected final compiler854fad098e62544b19115cbb2e5a8ed75dba33a47a5d5ccb94acce27bff47d28 with rustc1.100.0, recorded MinGW10. Host and pool exit0/empty stderr. Native Linux non-ASAN pool binary arguments double, size, owner each deliberately abort with the named integrity diagnostic. Do not count those as successful normal runs. For PE host use cross-gcc -O1 -Iruntime and-lm; for the pool unit use cross-gcc -O2 -flto -ffunction-sections -fdata-sections -Wl,--gc-sections to eliminate unreferenced evaluator routines from the included C unit, then execute with Wine.

```
python3 tests/macro/p1/matrix.py
python3 tests/macro/p1/matrix.py --target windows
HB_BASE_COMPILER=/tmp/hr-n1-hbc HB_B2_COMPILER=/tmp/hr-p1-hbc python3 tests/memvar/context-macro/battery.py --target linux --start 0 --end 1743
HB_BASE_COMPILER=/tmp/hr-n1-hbc HB_B2_COMPILER=/tmp/hr-p1-hbc python3 tests/memvar/context-macro/battery.py --target windows --start 0 --end 1743
python3 tests/memvar/context-macro/summarize.py
HB_M2_COMPILER=/tmp/hr-p1-hbc python3 tests/macro/m2/fatal-matrix.py --target linux
HB_M2_COMPILER=/tmp/hr-p1-hbc python3 tests/macro/m2/fatal-matrix.py --target windows
python3 tests/macro/p1/bench.py
python3 tests/macro/p1/bench-base.py
```

Start Wine server-p180, warm with a PE before a batch, then stop-k/-w after. Prefix/tmp/hr-m2-wine11-prefix. Do not treat startup errors as passes. Benchmark baseline and candidate have the same50000-iteration inputs; six process samples, median lastfive. Timing includes startup. Read the dated report: P1 is still slower than Harbour.

For inherited positive/ABI/limits runners that hardcode the M2 compiler path, retain source unchanged and replace only that executable at runtime:

```
python3 - <<'PY'
from pathlib import Path
for name in ['positive','abi','limits','pe-controls']:
 p=Path('tests/macro/m2/'+name+'.py')
 exec(compile(p.read_text().replace('/tmp/hr-m2-hbc','/tmp/hr-p1-hbc'),str(p),'exec'),{'__file__':str(p.resolve())})
PY
```

Full battery is external-GAS execution; other production PRG runners use internal executable writers. Matrix asserts no new oracle mismatch and every changed output exact, but all270 lines are also explicitly checked identical to N1BASE in the review consolidation. Raw channels remain separate. Tests add no error-buffer representation change and no extra builtin names.

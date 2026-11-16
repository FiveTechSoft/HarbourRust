# P1b reproduction

Run at source root. Recorded environment paths in these engineering runners are explicit; adapt them for another installation. Harbour pin694428e1c12f726675b19324d62167fa77d68185, MinGW GCC10-posix20220113 and local Wine11 setup are described in tests/macro/m2/REPRODUCE.md. BASE is D1 commit92f5c7afbb08736c18035afc606d74b335ee82aa, not the earlier P1-only source. Build it separately as /tmp/hr-p1b-base-hbc, expected1dfdb8722aeb7c043f437aaf1b758bdf292fa9e3da82f419f4147d5d4fb6f312.

```
HR_MACRO_CC=/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-gcc-posix python3 tests/generate_macro_asm.py
rustc --edition=2021 -C opt-level=1 -C debuginfo=0 -C strip=symbols src/hbc.rs -o /tmp/hr-p1b-hbc
gcc -std=c99 -O1 -g -Iruntime -fsanitize=address,undefined tests/memvar/context-macro/host.c runtime/hrmacro.c runtime/hrmemvar.c runtime/hrmembridge.c -lm -o /tmp/hr-p1b-host-asan
ASAN_OPTIONS=detect_leaks=1 /tmp/hr-p1b-host-asan
python3 tests/macro/p1b/errors.py
python3 tests/macro/p1b/errors.py --target windows
python3 tests/macro/p1b/matrix.py
python3 tests/macro/p1b/matrix.py --target windows
```

Expected candidate5b07beec563a572e021489876f7ca24321ea36abbe079127b7997990960559a4 with rustc1.100.0 and recorded generator. Host10 lines, empty stderr/exit0. PE host uses cross-gcc -O1 -Iruntime and-lm without sanitizers; run under Wine. The24-case errors runner compares raw streams to BASE, not all to official Harbour: unknown-call stage limits intentionally differ. Its bracket string literals preserve nested mixed quotes without Python-style escapes.

```
HB_BASE_COMPILER=/tmp/hr-p1b-base-hbc HB_B2_COMPILER=/tmp/hr-p1b-hbc python3 tests/memvar/context-macro/battery.py --target linux --start 0 --end 1743
HB_BASE_COMPILER=/tmp/hr-p1b-base-hbc HB_B2_COMPILER=/tmp/hr-p1b-hbc python3 tests/memvar/context-macro/battery.py --target windows --start 0 --end 1743
python3 tests/memvar/context-macro/summarize.py
HB_M2_COMPILER=/tmp/hr-p1b-hbc python3 tests/macro/m2/fatal-matrix.py --target linux
HB_M2_COMPILER=/tmp/hr-p1b-hbc python3 tests/macro/m2/fatal-matrix.py --target windows
python3 tests/macro/p1b/bench.py
python3 tests/macro/p1b/bench-base.py
```

Start Wine server-p180 and warm it with a PE before a batch, then-k/-w afterward. Default prefix/tmp/hr-m2-wine11-prefix, executable/tmp/hr-wine11/opt/wine-stable/bin/wine. Do not count startup errors as passes. Full battery uses external GAS/ld; production PRG error/matrix/fatal runners use internal writers. Benchmarks have identical50000-evaluation inputs, six process samples/median lastfive, include startup, and retain raw samples. Read the dated report: strings are near parity but not measured faster than Harbour; no global speed win.

For inherited positive/ABI/limits runners with hardcoded M2 compiler path, leave the tracked files unchanged and select P1b at execution:

```
python3 - <<'PY'
from pathlib import Path
for name in ['positive','abi','limits','pe-controls']:
 p=Path('tests/macro/m2/'+name+'.py')
 exec(compile(p.read_text().replace('/tmp/hr-m2-hbc','/tmp/hr-p1b-hbc'),str(p),'exec'),{'__file__':str(p.resolve())})
PY
```

Recipe dependency hashes and regenerated blob identity are required. This increment contains only compact error representation, not a semantic cache, new builtins or changes to D1 fields/file modes.

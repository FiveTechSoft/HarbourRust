# N1 reproduction

Run at repository root. This is an engineering evidence runner with explicit recorded-environment paths, not a portable installed test suite. Follow tests/macro/m2/REPRODUCE.md for installing/pinning Harbour, MinGW10 and Wine11. N1 BASE is 00e1d81ccdef2c7eed5f462a5da2f9d9fe84122b, whose compiler-producing code is byte-identical to M2 5cdc4d50. BASE compiler /tmp/hr-m2-hbc has SHA256 f7710cde87065e30f51900020f77f00d86947441bcff7802a7a30ba9554b0841.

```
HR_MACRO_CC=/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-gcc-posix python3 tests/generate_macro_asm.py
rustc --edition=2021 -C opt-level=1 -C debuginfo=0 -C strip=symbols src/hbc.rs -o /tmp/hr-n1-hbc
sha256sum /tmp/hr-n1-hbc
gcc -std=c99 -O1 -g -Iruntime -fsanitize=address,undefined tests/memvar/context-macro/host.c runtime/hrmacro.c runtime/hrmemvar.c runtime/hrmembridge.c -lm -o /tmp/hr-n1-host-asan
ASAN_OPTIONS=detect_leaks=1 /tmp/hr-n1-host-asan
python3 tests/macro/n1/matrix.py
python3 tests/macro/n1/matrix.py --target windows
```

Expected compiler cc844ba32064085b7bf25c79343fa65f437d3d549e4442096bb545b91e02f6d1 with recorded toolchain. Expected host eight PASS lines, no stderr, exit0. For PE host, compile with x86_64-w64-mingw32-gcc-posix -Iruntime and -lm, without sanitizers; run under Wine.

Start wineserver -p180 and warm it with an emitted PE before each Windows batch. Stop with wineserver -k then -w afterward. Matrix defaults: /tmp/hr-n1-hbc candidate, /tmp/hr-m2-hbc BASE, /tmp/hr-oracle-current/core-694428e1c12f726675b19324d62167fa77d68185 oracle, /tmp/hr-wine11/opt/wine-stable/bin/wine, /tmp/hr-m2-wine11-prefix. Change these explicit paths for another installation. Each target records separate raw channels, all 270 expression mappings, BASE/candidate/oracle line values. It asserts no BASE-pass/oracle-fail regression and every changed line exact to oracle; it does not assert all inherited rows pass.

Full regression:

```
HB_BASE_COMPILER=/tmp/hr-m2-hbc HB_B2_COMPILER=/tmp/hr-n1-hbc python3 tests/memvar/context-macro/battery.py --target linux --start 0 --end 1743
HB_BASE_COMPILER=/tmp/hr-m2-hbc HB_B2_COMPILER=/tmp/hr-n1-hbc python3 tests/memvar/context-macro/battery.py --target windows --start 0 --end 1743
python3 tests/memvar/context-macro/summarize.py
HB_M2_COMPILER=/tmp/hr-n1-hbc python3 tests/macro/m2/fatal-matrix.py --target linux
HB_M2_COMPILER=/tmp/hr-n1-hbc python3 tests/macro/m2/fatal-matrix.py --target windows
```

HB_B2_COMPILER/HB_M2_COMPILER are inherited variable names selecting N1. Full battery uses captured assembly plus external GAS/ld. For the M2 positive rerun without changing its tracked script, execute it with its hardcoded compiler path replaced at runtime:

```
python3 - <<'PY'
from pathlib import Path
p=Path('tests/macro/m2/positive.py')
exec(compile(p.read_text().replace('/tmp/hr-m2-hbc','/tmp/hr-n1-hbc'),str(p),'exec'),{'__file__':str(p.resolve())})
PY
```

The positive and fatal runners and matrix all use the internal executable writers. The matrix oracle changes only hb_memcheck() to0, leaving the product's actual allocation check active. Source recipe hashes, raw evidence and the dated N1 report identify the measured limits.

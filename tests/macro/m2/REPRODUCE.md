# M2 reproduction

Run at the source-tree root. The scripts currently default to the paths of the recorded test environment; set the documented environment variables where available or update those explicit tool paths to your local installs. They are engineering evidence runners, not a portable installed test suite.

## Build and identity

```
HR_MACRO_CC=/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-gcc-posix python3 tests/generate_macro_asm.py
rustc --edition=2021 -C opt-level=1 -C debuginfo=0 -C strip=symbols src/hbc.rs -o /tmp/hr-m2-hbc
sha256sum generated/hrmacro.s /tmp/hr-m2-hbc
```

Expected: asm 2e16431ec89c7f62edf309189af6b298e7457a523f288233452829188b2e1c06, compiler f7710cde87065e30f51900020f77f00d86947441bcff7802a7a30ba9554b0841, with recorded MinGW GCC10 and rustc1.100.0 on this host. Read generated/hrmacro_recipe.json for all flags/dependencies. Do not regenerate with another compiler and assume byte identity. No symbolic address .quad/.long or movabs is allowed in the blob.

## Host cleanup and sanitizers

```
gcc -std=c99 -O1 -g -Iruntime -fsanitize=address,undefined tests/memvar/context-macro/host.c runtime/hrmacro.c runtime/hrmemvar.c runtime/hrmembridge.c -lm -o /tmp/hr-m2-host-asan
ASAN_OPTIONS=detect_leaks=1 /tmp/hr-m2-host-asan
```

Expected seven PASS lines, no stderr, exit0. The include search path is required by the inherited bridge-client includes. For PE use x86_64-w64-mingw32-gcc-posix with -Iruntime and -lm, without sanitizers; execute under the recorded Wine environment.

## Production output/oracle/ABI gates

Official Harbour: commit 694428e1c12f726675b19324d62167fa77d68185. Build its Linux gcc and cross-mingw64 libraries plus hbmk2; the scripts default to /tmp/hr-oracle-current/core-694428e1c12f726675b19324d62167fa77d68185. Cross compiler defaults /tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-*. Local Wine11 default /tmp/hr-wine11/opt/wine-stable/bin/wine; prefix /tmp/hr-m2-wine11-prefix. Start wineserver -p180 and warm it with any emitted test executable before a batch; stop with wineserver -k then -w afterward. Startup timeouts/intermittent older Wine service errors are not test passes.

```
python3 tests/macro/m2/positive.py
python3 tests/macro/m2/fatal-matrix.py --target linux
python3 tests/macro/m2/fatal-matrix.py --target windows
python3 tests/macro/m2/limits.py
python3 tests/macro/m2/pe-controls.py
python3 tests/macro/m2/abi.py
```

HB_M2_COMPILER and HB_ORACLE_CORE override the fatal runner. The other small runners use their explicit paths. Run limits before pe-controls: its source fixtures are reused there. Fatal results-00-16.json are authoritative; earlier partial/replay files are historical. The unknown-call limit is not compared with an interactive oracle. Round +/-16 is an explicit stage divergence. ABI harness uses actual emitted helpers linked to a C test entry, not the host's stub dispatch.

## Full manifest regression and emission captures

Build BASE d0b102abe44d8caa6ffbba9fad5d1fb5fbdcfb40 with the same rustc options as candidate into /tmp/hr-m2-base-hbc. On each target:

```
HB_BASE_COMPILER=/tmp/hr-m2-base-hbc HB_B2_COMPILER=/tmp/hr-m2-hbc python3 tests/memvar/context-macro/battery.py --target linux --start 0 --end 1743
HB_BASE_COMPILER=/tmp/hr-m2-base-hbc HB_B2_COMPILER=/tmp/hr-m2-hbc python3 tests/memvar/context-macro/battery.py --target windows --start 0 --end 1743
python3 tests/memvar/context-macro/summarize.py
```

HB_B2_COMPILER is the inherited variable name; it selects this M2 candidate. HB_WINE/WINEPREFIX override the Wine defaults. The battery emits assembly, uses external GAS/ld, records separate raw stdout/stderr/rc and stores complete gzip assembly and changed-emission diffs. It is not an internal-writer end-to-end test. Separate positive/fatal/capacity gates above use the internal writers. The 1743 count includes negative tests and 12 PE positives blocked by inherited compile limits. Read the dated M2 report before interpreting the legacy fixture mismatch count or the secondary newline-normalized column.

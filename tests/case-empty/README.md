# Upper/Lower empty owned pointer regression

Published BASE0aa58a2 can crash after Upper("") or Lower(""): the empty branch bypasses capture of hbc_strcpy's allocated result in r10, then the common return reads r10 as its pointer. Output can be correct before later cleanup faults. Upper(Space(0)) reproduces too. The fix moves `mov %rax,%r10` before the length test in both helpers. No numeric admission, case mapping, metadata safe list or ABI change.

Build and run from the repository root:

```
rustc --edition=2021 -O -C strip=symbols src/hbc.rs -o /tmp/hbc-fixed
python3 tests/case-empty/check.py --compiler /tmp/hbc-fixed --hbmk2 "$HB" --output /tmp/case-empty-gate
python3 tests/case-empty/abi.py --compiler /tmp/hbc-fixed --output /tmp/case-empty-abi
```

HB is real Harbour hbmk2, pinned by review to694428e1c12f726675b19324d62167fa77d68185. Add `--wine /path/to/wine --wine-prefix /path/to/prefix` for PE/Wine execution. abi.py also needs `--mingw /path/to/mingw/bin --mlib /path/to/mingw/lib` for GNU PE assembly. Wine is not native Windows.

check.py compares exact Harbour output and final hb_memcheck0 after Work returns for basic and loop fixtures, normal/instrumented on Linux/PE. Fixtures include empty literals, allocated empty Space results, assigned empties,10000 repeated empty transforms, embedded NUL and255 bytes, and nonempty mixed-case controls. Oracle raw bytes are retained; no output-only or rc0-only ownership success is claimed.

abi.py calls helpers directly with r10 poisoned to99 before every call. It checks valid owned pointer/length/header, transformed bytes, callee-saved registers, stack, frees every result and flushes the cache; logical allocation balance and instrumented registry must end0. Each Upper/Lower length0/1/3 case repeats three times, across GNU Linux/PE normal/instrumented. This is18 cases per process, four successful probe processes. No new assembly instruction is added.

Also run the full existing manifest. Baseline-isolation JSON in review evidence records the published BASE failure separately; old crashing runs are not PASS. The Upper safe_builtin micro remains parked and must be rebased on the published fix before continuing.

Limits: this fixes empty result-pointer initialization only. ASCII byte mapping and its existing non-ASCII limitations are unchanged; no locale/casefold expansion. General owned TRY-error cleanup gaps remain. No benchmark or native Windows performance claim.

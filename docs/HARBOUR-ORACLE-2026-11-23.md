# Harbour oracle (github.com/harbour/core) - 2026-11-23

Status: record. Built from the pinned Harbour tree at `/home/fivetech/harbour`
(a native aarch64 checkout of github.com/harbour/core, Harbour 3.2.1dev,
r2026-07-07, Aleksander Czajczynski, tree `0d3b43954a` at the time of
measurement; `bin/hbmk2 --version` prints that banner). The oracle is
compiled, not interpreted, so its output is byte-identical to what the real
oracle produces on this host.

This record documents how the oracle was set up and what it says for the
13 Linux-subset `neg` cases recorded on 2026-11-23, plus the hello.prg sanity
check at the start.

## Setup (no Harbour tree was modified)

`bin/hbmk2` from the Harbour tree invokes `gcc` with `-I<harbour>/include`.
That include dir contains untracked stale stub headers that shadow the system
headers on this host (and would break the C compile on any modern glibc):

- `include/stdio.h`, `include/stdarg.h`, `include/stddef.h`, `include/stdint.h`:
  harbour-era stubs (`/* Stub for Harbour C compiler */`; `stdio.h` is an
  unterminated `#ifndef`, `stdarg.h` defines `typedef int va_list` and broken
  macros)
- `include/bits/` (`types.h`, `wordsize.h`, `libc-header-start.h`): stubs that
  shadow the system `bits/types.h` and conflict with modern glibc
  (`__locale_t` redefinition)

These are untracked files, not part of the Harbour tree's tracked checkout
(nothing in `git ls-files` references them). They were NOT removed from the
Harbour tree. The oracle is built with the stale files excluded instead:

```
mkdir /tmp/oracle-inc && cp -a /home/fivetech/harbour/include/. /tmp/oracle-inc/
rm -rf /tmp/oracle-inc/bits
rm -f /tmp/oracle-inc/stdio.h /tmp/oracle-inc/stdarg.h \
      /tmp/oracle-inc/stddef.h /tmp/oracle-inc/stdint.h
export HB_INSTALL_INC=/tmp/oracle-inc
/home/fivetech/harbour/bin/hbmk2 <.prg> -gtstd -o./<bin>
```

`hbmk2` honors the `HB_INSTALL_INC` environment variable for its `-I`
include path (`utils/hbmk2/hbmk2.prg` line 1096, consumed at line 1209), so
the oracle can be pointed at a clean include set without touching the user's
Harbour checkout. The remaining untracked files are symlinks to the system
GCC headers (`arm_*.h`, `omp.h`, `stdalign.h`, `gcov.h`, `syslimits.h`, etc.)
and are kept as-is. The link step reads only from the read-only Harbour
tree (`libharbour.so`, `libgtstd.a`).

Oracle run shape: `hbmk2 <prg> -gtstd -o./<bin>` (a native aarch64 binary,
like the rest of the Harbour install), then execute directly.

## Sanity check

`tests/samples/hello.prg` via the oracle: output byte-identical to
`tests/expectations/qout/hello.linux.out` (`cmp` clean, 32 bytes:
`\nresultado de z:\n        32\nhola desde una funcion`).

## t436 / t988 / t1068 / t1691 - four Linux-stale neg rows

All four programs COMPILE cleanly under compiled Harbour and RUN with no
rejection. This is the same shape as the main-only acceptance: the Harbour
behaviour is shared-and-accepting, not rejecting. The manifest recorded a
Linux rejection that the Linux compiler no longer enforces.

| Case | Source (shape, not copyrighted) | Oracle behaviour |
| --- | --- | --- |
| tests/t436_neg_darrs_arg_moved.prg | `local a := {}; AAdd(a, "uno"); ? mut(a); ? len(a)` with `mut` returning 0 | compiles, runs, exits 0: `0` then `2` (the caller's `a` GREW - Harbour SHARES the array between call and callee, the registered D5/D7-family difference from HarbourRust's move) |
| tests/t988_inline_if_dyn_limit_neg.prg | `local x := NIL; ? If(.T., x, NIL)` | compiles, runs, exits 0, output `.NIL` (the taken branch evaluates and prints) |
| tests/t1068_minmax_mixed_neg.prg | `? Min(1, 1.0)` | compiles, runs, exits 0, output `         1` (int result) |
| tests/t1691_iif_mixed_neg_dynvar.prg | `local y := NIL; local x := iif(.T., y, 1)` (dead result) | compiles, runs, exits 0, no output |

The Linux relaxation is real and deliberate-looking (the manifest expectation
was recorded before the Linux-only gates in main: CTOD untyped LOCAL, VAL
Dyn local, argument-count tracking, scoped optional array mutation). NOT
re-pinned here. The maintainer's options are:

1. Re-pin these four rows as positive cases with the oracle outputs above as
   expectations (byte-exact, both targets' shapes differ on Linux), or
2. Revert or tighten the Linux gate so the named rejection comes back.

(The Windows diagnostic for these four cases still matches the manifest
substring, so the pending Linux decision is confined to Linux.)

## t1634 / t1635 / t1636 / t1637 / t1638 / t1639 / t1640 / t1641 / t1642 - nine CurDir neg rows

All nine COMPILE cleanly under compiled Harbour. `CurDir` is a Harbour
install builtin (the native RTL reads the actual cwd; no argument is needed
and Harbour silently ignores extra arguments after evaluating them).
HarbourRust intentionally enforces a stricter contract documented in
`docs/BASELINE-2026-11-13.md` ("Variables, effectful expressions, numeric/
logical/array arguments, by-reference forms and extra arguments reject
conservatively, even though Linux Harbour ignores some of those values after
evaluating them").

| Case | Source (shape) | Oracle behaviour |
| --- | --- | --- |
| t1634_extra | `? CurDir("C",1)` | compiles, runs, exits 0, output = current cwd |
| t1635_number | `? CurDir(1)` | compiles, runs, exits 0, output = cwd |
| t1636_logical | `? CurDir(.T.)` | compiles, runs, exits 0, output = cwd |
| t1637_variable | `LOCAL s := "C"; ? CurDir(s)` | compiles, runs, exits 0, output = cwd |
| t1638_effect | `LOCAL n := 0; ? CurDir(n++)` | compiles, runs, exits 0, output = cwd (the effect runs) |
| t1639_array | `? CurDir({})` | compiles, runs, exits 0, output = cwd |
| t1640_function | `? CurDir(Drive())` with `Drive()` returning `"C"` | compiles, runs, exits 0, output = cwd |
| t1641_dead | `IF .F. ? CurDir(1) ENDIF` | compiles, runs, exits 0, no output |
| t1642_byref | `LOCAL s := "C"; ? CurDir(@s)` | compiles, runs, exits 0, output = cwd |

The oracle confirms: **the nine CurDir rejections are intentional
conservative rejections by HarbourRust, in both the intentional Linux
rejection and the Windows "not in this increment" diagnostic**. They are
the registered conservative boundary, not a regression or a stale
expectation. The 9 rows stay as `neg` expectations.

## Known limitations of this record

- The oracle here covers the 13 `neg` cases above plus `hello.prg`. All other
  positive rows still need the x86-64 harness (e.g. the full battery) to
  complete the verification.
- `CurDir` output is environment-dependent (the cwd), so only compile
  behaviour and exit status are recorded; the path string is only verified
  to be the harness cwd (`/tmp/oracle`), not across every context.
- No oracle comparison is claimed for Windows/PE execution (the oracle here
  is the Linux-class compiled driver; the committed Windows view is
  `tests/fs-*/windows-manifest` records instead).

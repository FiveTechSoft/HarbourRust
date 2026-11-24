# Harbour oracle (github.com/harbour/core) - 2026-11-23

Status: record. Built from the pinned Harbour tree at `/home/fivetech/harbour`
(a native aarch64 checkout of github.com/harbour/core, Harbour 3.2.1dev,
r2026-07-07, Aleksander Czajczynski, tree `0d3b43954a` at the time of
measurement; `bin/hbmk2 --version` prints that banner). The oracle is
compiled, not interpreted, so its output is byte-identical to what the real
oracle produces on this host.

This record documents how the oracle was set up and what it says for the
16 Linux-subset `neg` cases recorded on 2026-11-23/24 (four stale on Linux
since the Linux-only gates, plus three more stale since the Set/fixed-cell/
shared-array landings of 2026-11-24), plus the hello.prg sanity check at the
start.

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

The Linux relaxation is real and deliberate: each row has a confirmed
root cause in the current source (`src/hbc.rs` + `src/shared_local.rs`), and
the oracle confirms the relaxed behaviour is what Harbour does. NOT
re-pinned here. The maintainer's options are:

1. Re-pin these four rows as positive cases with the oracle outputs above as
   expectations (byte-exact, both targets' shapes differ on Linux), or
2. Revert or tighten the Linux gate so the named rejection comes back.

(The Windows diagnostic for these four cases still matches the manifest
substring, so the pending Linux decision is confined to Linux.)

### Root causes (2026-11-23, against the current tree)

| Case | Root cause in current source |
| --- | --- |
| t436 | `main`'s local `a := {}` enters shared-local discovery
  (`shared_local::init`, `src/shared_local.rs`): `a` lowers into the
  shared module-array family for self-owned AAdd params (commit
  `001fcdee`, "Select shared local array identity for explicit self-cell
  cycles"), so the callee's `x` is pinned to Dyn (`"mut params [I64] ->
  [Dyn]"` under `HBC_INFER_TRACE=1`) through the `shared_local::parameter`
  branch (`src/hbc.rs:4937`). `a` is therefore shared and mutated in place
  - it never moves - so the move-ownership diagnostic in `Expr::Var` can
  no longer fire. The caller's array keeps growing in place, exactly like
  Harbour's behavior (the `0\n2` oracle output above), so the manifest's
  "use of moved value `a`" expectation is superseded - not a lost check. |
| t988 | The inline Dyn-`iif` gate is now implemented on Linux (`allow_mixed_iif`
  in `check_stmts`, plus the Dyn slot representation for locals), so the
  rejection "branches must share a scalar type" is intentionally gone.
  The oracle prints the taken branch (output `.NIL`). Windows still
  rejects, preserving the manifest substring there. |
| t1068 | Mixed numeric `Min`/`Max` (int literal vs F64 literal) is now
  implemented on Linux (the float-boundary/literal fold in `type_expr`
  propagates F64 through the argument fold, producing `1`), so the
  rejection "needs matching integer, float or logical arguments" is
  intentionally gone. Windows still rejects. |
| t1691 | Mixed-iif with a Dyn local (`local y := NIL; local x := iif(.T., y, 1)`)
  is accepted on Linux by the same mixed-iif machinery (the Dyn-local
  `iif` path, `allow_mixed_iif`), so the rejection is gone. Windows
  still rejects. |

Note also that the shared-local family gives the owner's slot a tagged
`{tag 16, object pointer}` shape rather than a `{descriptor, kind}` pair, and
`? len(a)` takes the generic Dyn-variable len path (`src/hbc.rs:7538`) -
the tag-16 runtime dispatch lands at the C-emit layer, not the checker.

## t813 / t897 / t1043 - three more Linux-stale neg rows (2026-11-24)

The full 622-row Linux `neg` check was rerun on 2026-11-24 after the
recent Linux-only landings (Set date-format selector 4, ordinary fixed
cell increments, bare-local string-copy rewrite). Three additional rows
now accept instead of rejecting. All three are manifest-sync gaps from
their feature commits (the repo convention in
`tests/manifest.txt` - re-pin in the same PR - was missed), not
regressions: each row's expectation was deleted by the feature, not by a
behaviour change to the existing checker.

| Case | Source (shape) | Oracle behaviour (compiled Harbour) |
| --- | --- | --- |
| tests/t813_set_callstmt_neg.prg | `Set(_SET_DATEFORMAT, "yyyy-mm-dd")` (selector 4 = date format, mask admitted by 5b40695b) | compiles, runs, exits 0, no output |
| tests/t897_inc_elem_neg.prg | `local a := {1,2}; ? a[1]++` (ordinary fixed integer cell increments, 0f39467f) | compiles, runs, exits 0, output `1` (post-increment prints the pre-increment value) |
| tests/t1043_original_longstr2_move_neg.prg | original longstr2 shape (OutErr/QOut/OutStd triple with `short`/`long`/`very_long`) | compiles, runs, exits 0, prints the length triple `10 / 40960 / 1310720` and the long strings (no moved-source rejection) |

The Linux compiler still accepts each of the three with rc=0 (verified
2026-11-24). The Windows/PE side behavior is unchanged from the 2026-11-23
record. NOT re-pinned here: the same manifest-sync gap category as the
four stale rows, and the same sign-off path:

1. Re-pin these three as `pos2` rows (oracle-confirmed values), or
2. Leave as documented debt until the next baseline, and re-run the
   full 622-row check + the PE gate afterwards.

## shared-shift-scalar-root probe (newest landing, 2026-11-24)

`tests/shared-shift-scalar-root/scalars.prg` (AIns/ADel statement gate,
commit f575742a) compiled with the native oracle (hbmk2 -gtstd -w0, Linux
aarch64, Harbour 3.2.1dev r2607071005) and run byte-for-byte:

- exits 0, zero stderr, deterministic output across runs
- 117 iterations: 5 scalar roots (int 17, word, float 19.25, .T., NIL)
  printed unchanged by AIns/ADel (index evaluated once, no mutation)
- NIL root prints `U` - scalar roots preserved, never forcibly cloned
- mixed array case (AClone({3,"word",19.25}), AIns(a,2), ADel(a,1))
  prints the post-shift root `U word U` (ValType(a[1]),a[2],ValType(a[3]))
- `? n` prints 1170 (10 index effects per iteration: 5 roots x
  AIns/ADel)
- output 703 lines / 5276 bytes (measured 2026-11-24)

The hbc side of this same gate (native/external/flat/noescape/noprune
modes, strict final balance, PE/macho/macho-arm64 rejection asserts) is
**not verifiable on this host**: hbc's Linux output is x86-64 ELF and
cannot be executed on aarch64 (verified: `exec` gives
`Exec format error`). The modes are CI/Linux-x86-64 gates per the
suite's own README; the oracle side captured above complements them but
is not a substitute for the hbc gates.

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

- The oracle here covers the 16 `neg` cases above plus `hello.prg`. All other
  positive rows still need the x86-64 harness (e.g. the full battery) to
  complete the verification.
- `CurDir` output is environment-dependent (the cwd), so only compile
  behaviour and exit status are recorded; the path string is only verified
  to be the harness cwd (`/tmp/oracle`), not across every context.
- No oracle comparison is claimed for Windows/PE execution (the oracle here
  is the Linux-class compiled driver; the committed Windows view is
  `tests/fs-*/windows-manifest` records instead).

# `--harbour-rdd`: real Harbour RDD for DBF access (opt-in, Windows)

`hbc x.prg x.exe --target=windows --harbour-rdd --harbour-dir=<harbour>`
builds `x.exe` in one step with Harbour 3.2's own VM and RDD (DBFCDX,
DBFNTX, DBFFPT) behind hbc's DBF seam. Reads, writes, memo fields, CDX/NTX
index creation with VM-evaluated key expressions, seeks and several work
areas then behave like Harbour. They are checked byte for byte against
Harbour 3.2 by the gate in `tests/dbf/harbour-rdd/`.

Without the flag nothing changes: hbc keeps its own MIT read-only DBF/NTX/CDX
reader and its internal PE writer. The default assembly of every program in
`tests/manifest.txt` is byte-identical to the compiler without this change
(see Verification).

## Usage

```
hbc x.prg x.exe --target=windows --harbour-rdd --harbour-dir=C:/harbour   static (default)
hbc x.prg x.exe --target=windows --harbour-rdd --harbour-dll              harbour-32-x64.dll
hbc x.prg x.s   --target=windows --harbour-rdd                            assembly only
```

- `--harbour-dir=<dir>`, or the `HB_DIR` environment variable: a Harbour 3.2
  mingw64 install (`include/`, `lib/win/mingw64/`; `bin/harbour-32-x64.dll`
  for `--harbour-dll`).
- MinGW-w64 `gcc` on `PATH`, or `HBC_GCC=<path>`. The user needs a C
  toolchain in this mode: Harbour's libraries have to be linked.
- `--harbour-dll` links the import library and copies `harbour-32-x64.dll`
  next to the executable if it is not already there.
- These fail with an explicit message: a missing install or gcc,
  `--harbour-dir`/`--harbour-dll` without `--harbour-rdd`, and
  `--harbour-rdd` with a non-Windows target, LLVM, Mach-O, `--external-as`
  or threads (Harbour's single-thread VM is linked).

## Design

**One seam.** Default-mode code calls the SysV `hrdbf_app_*` entry points
(`runtime/hrdbf_app.c`, embedded as `generated/hrdbf_windows.s`). Under the
flag hbc emits the same calls but does not embed that reader.
`runtime/hrharbour_rdd.c` (own MIT) implements the same names and ABI over
Harbour's VM:

| hbc call | entry | Harbour |
|---|---|---|
| `dbUseArea(lNew, "DBFCDX"\|"DBFNTX", cFile, "ALIAS", lShared, lReadonly)` | `hrdbf_app_open6` | `DBUSEAREA` |
| `dbGoTop/Bottom`, `dbSkip`, `dbGoto(n)`, `RecNo`, `LastRec`, `Bof`, `Eof`, `Deleted`, `Found` | `hrdbf_app_*` | same-named functions |
| `FieldGet(n)` | `hrdbf_app_get` | `FIELDGET` |
| `NAME`, `ALIAS->NAME`, `FIELD->NAME` (reads) | `hrdbf_app_alias_select` + `hrdbf_app_fieldpos` + `hrdbf_app_get` | work-area select, field index |
| `ALIAS->NAME := v`, `FIELD->NAME := v` | `..._fieldpos` + `hrdbf_app_put` | the RDD's `PUTVALUE`, as the VM's field store |
| `FieldPut(n, v)` | `hrdbf_app_fieldput` | `FIELDPUT` |
| `dbAppend`, `dbCommit`, `dbDelete`, `dbRecall` | `hrdbf_app_*` | same-named functions |
| `ordCreate(cBag, cTag, cKey)` | `hrdbf_app_ordcreate` | `ORDCREATE` without a block: the RDD macro-compiles `cKey` |
| `ordSetFocus(cTag)`, `OrdListAdd`, `OrdListClear`, `dbSeek(c[, soft[, last]])` | `hrdbf_app_*` | same-named functions |

Values cross as hbc's 16-byte Dyn cell (`hrv_cell`, `runtime/hrvalue.h`).
Field reads come back as the cells the default reader produces: owned
string, scaled field numeric with width and decimals, packed Date, logical.
Memo fields come back as strings. Writes accept integer, float, string,
logical and Date values (hbc's `cg_data_value`).

**Field-name lowering** reuses the parser's `dbffieldref(name[, ALIAS])` and
the bare-identifier rewrite from 92f5c7a and 399e159. Under the flag, an
alias selects that work area for the read and restores the previous one.
That gives real multi-area programs. Missing fields and aliases still raise
`BASE/1003` and `BASE/1002` through `hrm_fail`, with hbc's frames.
`ALIAS->NAME := v` / `FIELD->NAME := v` statements lower to
`dbffieldput(name, alias, v)`.

**Bare `NAME := v` is rejected.** Harbour 3.2 does not store a bare
assignment to an undeclared name in the field; it assigns a memvar. The
measurement is gate case `x01_bare_assign`: Harbour leaves the table
unchanged. hbc does not create memvars implicitly, so it rejects the line
with a message that points to `FIELD->NAME := v`.

**Process shape.** The executable starts in the MinGW CRT. The shim's
`main()` does four things, in order:

1. registers the Harbour functions it calls by name (C-level `HB_FUNC`s are
   not dynamic symbols by themselves);
2. selects GTCGI (see Startup below for why);
3. calls `hb_vmInit(HB_FALSE)`, which starts the VM, ErrorSys and GT without
   a PRG main;
4. installs a low-level error handler and calls hbc's own `_start`.

Every `call ExitProcess` in hbc's emitted code becomes `call
hr_hb_exitprocess`. That runs `hb_vmQuit()` first, so normal exit, run-time
errors and hbc's panic path all close and flush every work area. Gate cases
`w05_no_close` and `e08_after_write` cover this.

**Errors raised inside Harbour** (RDD, FieldPut, key evaluation) reach the
shim's handler. It follows ErrorSys's `DefError` defaults: zero divide
gives 0, a lock error retries, and `NetErr(.T.)` is set for shared-open and
append-lock failures. Otherwise it formats ErrorSys's message (`Error
SUB/code  description: file|operation (DOS Error n)`) plus Harbour's own
frames (`Called from DBUSEAREA(0)`), and passes it to `hrm_fail`, which adds
hbc's frames and exits 1. This is the headless terminal profile of
docs/MACRO-ERROR-CONTRACT.md: like the rest of hbc, it does not print
Harbour's interactive Alert line on stdout.

**Link** (`src/hbrdd.rs`): the shim source is embedded in hbc and compiled
on every build (`gcc -c -O2`). The emitted assembly is assembled by gcc and
the result linked as follows:

- static: `-s -Wl,--gc-sections` and `hbvm hbrtl hbrdd rddcdx rddntx rddfpt
  hbsix hbmacro hbcommon gtcgi kernel32 winmm`. This set was measured as
  minimal by dropping each library in turn. The shim satisfies rtl/gtsys.c's
  reference to GTWIN with an empty stub, so GTWIN is not linked.
- DLL: `-lharbour-32-x64`.

## Licence

Harbour is GPL v2+ with the Harbour exception. From its LICENSE.txt:
"if you link the Harbour libraries with other files to produce an
executable, this does not by itself cause the resulting executable to be
covered by the GNU General Public License".

`runtime/hrharbour_rdd.c` and `src/hbrdd.rs` are own MIT code that call
Harbour's public C API. No Harbour source is copied. Only executables built
with `--harbour-rdd` contain Harbour library code. hbc itself, its default
runtime and default-mode executables do not, and the README's statement
that the runtime is own MIT code that does not link Harbour's VM/RDD still
holds for them.

## Measurements (2026-11-16, Windows 11, Harbour 3.2 mingw64, gcc 16.2)

Sizes (`ls`, single method):

| program | hbc default | `--harbour-rdd` static | `--harbour-rdd --harbour-dll` | Harbour 3.2 (oracle link, unstripped) |
|---|---|---|---|---|
| M_CLIE read (`? NOMBRE, EDAD, CLIE->NOMBRE`) | 30,208 | 1,295,360 | 43,008 + 5,659,779 DLL | - |
| gate r01_read | (not admitted: shared open, memo) | 1,296,896 | 44,544 + DLL | 1,594,612 |
| gate w01_append_cdx | (writes not admitted) | 1,299,968 | 48,128 + DLL | 1,594,618 |

Startup of the M_CLIE read program, per run. Two methods (Python
`perf_counter` median of 50 runs; PowerShell `Measure-Command` mean of 100
runs), no other battery running:

| build | Python median | PowerShell mean |
|---|---|---|
| hbc default (own reader) | 3.82 ms | 4.87 ms |
| `--harbour-rdd` static | 8.10 ms | 9.52 ms |
| `--harbour-rdd --harbour-dll` | 11.98 ms | 13.15 ms |
| Harbour 3.2 | 8.33 ms | 9.37 ms |

The static mode costs about 4.5 ms per process over the default reader,
which is the same as a Harbour executable. Without selecting GTCGI, the
console GT (GTWIN) became the default and startup measured about 75-80 ms
(spike, both methods).

## Gate: `tests/dbf/harbour-rdd/`

```
python tests/dbf/harbour-rdd/check_harbour_rdd.py --compiler ./hbc.exe \
  --harbour C:/HarbourRust/tools/harbour/pkg/win/mingw64/harbour-3.2.0-win-mingw64 \
  --mingw-bin C:/HarbourRust/tools/mingw/mingw64/bin [--modes static,dll]
```

`build_fixture.prg` writes `clie.dbf`+`clie.fpt` (DBFCDX) and `clin.dbf`
(DBFNTX) with real Harbour. Each program is built by Harbour and by hbc in
each link mode, and each build runs in its own fresh copy of the tables.
The gate compares exit code, stderr, stdout (Alert line removed, CRLF
normalised) and every `.dbf/.cdx/.ntx/.fpt` left behind, byte for byte.
Cases:

- reads: C/N(8,2)/L/D/memo, alias and `FIELD->`; two areas, then a field
  read with the current area closed (BASE/1003).
- writes:
  - append plus FieldPut of every type, two CDX tags with computed keys;
  - `ALIAS->`/`FIELD->`/`_FIELD->` stores, NTX create, seek and scan;
  - `ordSetFocus` with soft and exact seeks;
  - delete/recall;
  - exit without closing.
- errors: open of a missing file (DBFCDX/1001 with DOS error), append on a
  read-only area (1025), FieldPut type error (1020, nested frames), alias
  store type error, missing field on store (BASE/1003), unknown alias
  (BASE/1002), a bad index key (BASE/1081 from the macro-evaluated key).
- an hbc panic after writes (rc and files only; hbc's own bound-error text
  differs from Harbour's in every mode).
- bare `NAME := v`: hbc rejects it, and the Harbour run leaves the tables
  unchanged.

Result with this commit: **32/32 identical** (16 programs x static and DLL),
which includes the bare-assignment rejection in both modes.

## Verification of the default mode

- Assembly identity: every `.prg` in `tests/manifest.txt` was compiled with
  `--target=windows` and `--target=linux` (with `--instrument -I tests`) by
  the compiler at origin/main 399e159 and by this branch. Result: 2332
  outputs byte-identical, 0 different, and 1154 rejected by both with the
  same message and exit code (the negative cases).
- Native Windows battery (`tests/run_battery_win.sh`, 8 chunks of 250
  manifest lines): 1719 pass, 23 skip, 1 failure, `t735_float_carry10`
  (exact Windows bytes). Its assembly is identical to main's. It passed 3/3
  when re-run alone, and another battery was running in a sibling worktree
  at the time, so it is recorded as a load flake.

## Limits

- Windows x86-64 only; Linux would need the same shim against a Linux Harbour build.
- A C toolchain and a Harbour install are required at build time. The internal
  PE writer is not used in this mode.
- Literal driver, alias and flags in `dbUseArea`. `ordCreate` and
  `ordSetFocus` take literal strings. `dbSeek` keys are strings. Aliased
  expressions `ALIAS->(expr)`, `dbSelectArea`, `Select()`, `INDEX ON`/`USE`
  commands, `dbCreate`, locks (`RLock`/`FLock`), filters, scopes, relations,
  `SET` RDD options and codeblock keys are not admitted.
- `FieldPut` returns NIL in hbc (Harbour returns the value).
- Bare `NAME := v` on an undeclared name is rejected (see above).
- Harbour errors carry Harbour's frames for Harbour functions, then hbc's
  frames. Recoverable errors (`BEGIN SEQUENCE`/`TRY` around an RDD error)
  are not supported: the handler is terminal, like `hrm_fail`.
- The single-thread VM (`hbvm`) is linked; threads are rejected.
- The executable's CRT is the toolchain's UCRT. Harbour's mingw64 libraries
  link and run with it. This is the same pairing as the Harbour oracle builds.
- The DBF header's last-update date makes table bytes depend on the day the
  program runs (both sides of the gate run on the same day).

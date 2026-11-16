# DBF D1: exclusive read-write open mode and field-name access

Two separable pieces, published together because they share one acceptance
program (Antonio's `test3.prg`, kept verbatim under
`tests/dbf/acceptance-test3/`).

## Piece 1: `readonly=.F.` admitted (exclusive read-write OS open)

`dbUseArea` still requires six explicit arguments, one alias, a literal
`DBFNTX`/`DBFCDX` driver and `shared=.F.`. The sixth argument now accepts a
literal `.T.` or `.F.`:

- `readonly=.T.`: unchanged read-only snapshot open.
- `readonly=.F.`: the file opens read-write at the OS level, matching
  Harbour's exclusive `shared=.F./readonly=.F.` contract. Windows keeps the
  retained exclusive handle (`GENERIC_READ|GENERIC_WRITE`, share mode 0);
  Linux opens `O_RDWR|O_CLOEXEC`. Opening a read-only file with
  `readonly=.F.` fails explicitly, as Harbour's exclusive open does.

Field write operations (`FieldPut`, `REPLACE`, `dbAppend`, bare-name field
assignment) do NOT exist in this increment: they stay rejected, and the
snapshot is never flushed back, so the open mode carries no persistence
semantics. Index files (NTX/CDX) still open read-only; with no write
operations there is nothing to propagate to them.

Files: `runtime/hrdbf_file.h`, `runtime/hrdbf_file_linux.c`,
`runtime/hrdbf_file_windows.c`, `runtime/hrntx_file_linux.c`
(rename `open_ro` to parameterized `open_dbf`),
`runtime/hrntx_file_windows.c`, `runtime/hrdbf_embedded_linux.c`,
`runtime/hrdbf_app.c` (open signature + open-failure message),
`src/hbc.rs` (argument validation and the fifth `hrdbf_app_open` argument),
`tests/generate_windows_asm.py` (5-argument wrapper).

## Piece 2: bare field-name access (`? CLIENTE`)

In a program that calls the DBF adapter, an identifier the function never
declares follows Harbour's dynamic field resolution: a syntactic pre-codegen
lowering rewrites it to an internal `dbffieldref("name")` call, typed Dyn,
resolved at runtime against the open workarea by `hrdbf_app_get_name`
(case-insensitive, NUL-padded header names), with the same result channel
and copy callback as `FieldGet`.

Files: `src/hbc.rs` (`dbf_result`, validation arm, codegen arm, and the
`expr_uses_dbf`/`stmts_use_dbf`/`collect_declared`/`rewrite_field_*`
lowering), `runtime/hrdbf_app.c` (`hrdbf_app_get_ord` refactor,
`hrdbf_app_get_name`, `hrdbf_app_field_missing`),
`runtime/hrdbf_embedded_windows.c` (renames),
`tests/generate_windows_asm.py` (`hrdbf_app_get_name` sret wrapper).

Documented divergences and limits:

- A DECLARED variable wins over a same-named field (Harbour resolves the
  field unless `MEMVAR->` is used). This compiler is static; the declared
  name keeps its slot. Code-block parameters shadow fields inside the block.
- An identifier declared ANYWHERE in the function (a later `local cliente`)
  suppresses the field reading for the whole function; using it before its
  declaration stays the ordinary undefined-variable error.
- A name that is neither declared nor a field of the open area fails fast at
  runtime: `hbc: DBF field not found in the open area: <name>` (Harbour
  raises the recoverable `BASE/1003 Variable does not exist`).
- `ALIAS->FIELD` and `MEMVAR->` syntax, and field-name access with no open
  workarea, are outside this increment (the runtime fails explicitly on the
  latter via the ordinary no-workarea check).
- Field names are looked up at runtime, not validated at compile time: a
  typo in a DBF-active program now fails at runtime instead of compile time.
  That is Harbour's own dynamic resolution contract.

## Gates

- Linux oracle gate `tests/dbf/check_oracle.py`: 20/20 paired executions,
  10 same-source programs, byte-exact stdout/stderr/exit code against
  official Harbour pin `694428e1c12f726675b19324d62167fa77d68185` in normal
  and instrumented modes. New programs: `open-rw.prg` (readonly=.F. with
  DBFNTX and DBFCDX) and `fieldref.prg` (field-name access, mixed case,
  reopen readonly=.T.). New Harbour-built fixture `mclie.prg` producing
  `M_CLIE.DBF` (`CLIENTE C(40)`, `CODIGO N(6)`).
- Acceptance lane: `tests/dbf/acceptance-test3/test3.prg` is Antonio's
  program VERBATIM. It compiles and runs correctly under hbc. Harbour
  cannot oracle it byte-for-byte without a `REQUEST DBFCDX` line (Harbour
  only registers DBFCDX on request; hbc always incorporates it), so the
  oracle equivalence of the same operations is covered by `open-rw.prg` and
  `fieldref.prg`, and test3 runs as the hbc-only acceptance program.
- Compile-time rejections unchanged/extended: `shared=.T.`, non-literal
  readonly flag, five-argument form, bare-name field assignment
  (`CLIENTE := x`), and all field write APIs remain rejected.
- Runtime rejections: missing field name fails explicitly; `readonly=.F.`
  on read-only storage fails explicitly; `readonly=.T.` on the same file
  still opens.

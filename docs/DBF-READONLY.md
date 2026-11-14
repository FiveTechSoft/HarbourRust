# Read-only DBF support (v0.4.0)

HarbourRust implements a bounded dBASE III reader using its own MIT-licensed
native helpers. It does not link Harbour's RDD, VM or runtime. This is the first
DBF increment, not standard RDD compatibility.

## Admitted calls

Linux x86-64, ordinary assembly backend only:

```harbour
function Main()
   dbUseArea(.T., "DBFNTX", "customers.dbf", "CUSTOMERS", .F., .T.)
   dbGoTop()
   ? RecNo(), LastRec(), Bof(), Eof()
   ? FieldGet(1)
   dbSkip()
   dbCloseArea()
return nil
```

`dbUseArea` requires six explicit arguments: a literal new-area logical,
literal `"DBFNTX"`, filename string, nonempty literal alias, `.F.` for shared,
and `.T.` for read-only. Only one workarea may be open; alias selection is not
implemented. The driver name does not imply NTX support.

Calls: `dbUseArea`, `dbCloseArea`, `dbGoTop`, `dbSkip`, `RecNo`, `LastRec`,
`Bof`, `Eof`, `Deleted`, `FieldGet`. `dbSkip()` defaults to one record and
accepts positive, zero and negative skips. `dbUseArea` returns a logical;
close/top/skip return NIL. Deleted records remain visible in physical order.

Version-03 tables support C/N/L/D fields. Invalid field ordinals return NIL.
EOF exposes typed blank fields. Copied character fields survive skip and close.
Dates retain a blank value or YYYYMMDD and print in the existing mm/dd/yy format.
Numeric fields retain their width, decimal count and signed 64-bit scaled
coefficient. Decimal numeric fields can be copied, printed and queried with
`Empty`/`ValType`; I64 arithmetic and numeric comparison require decimal count
zero. Unsupported consumers fail explicitly rather than truncate values.

## Limits

- No NTX/CDX, memo, writes, shared locking, filtering, collation or codepage
  conversion. NTX is the next planned increment, followed by CDX.
- No Windows DBF or LLVM DBF backend.
- No general conversion between static Date values and dynamic DBF Dates.
  Mixed `CToD`/`Date` versus `FieldGet` Date comparison is rejected at compile time.
- New Date/numeric-field values are rejected in SWITCH and HScan. Dynamic
  double comparisons and string HScan queries also reject in DBF-active programs.
- Scalar arrays/hashes do not acquire an owned-string storage model through
  FieldGet. String Dyn values are rejected at scalar-container stores/add/fill
  boundaries. Numeric/logical/Date scalar cells remain admitted.
- `HB_ISNUMERIC` over a general Dyn variable remains outside the subset;
  admitted array-cell classification recognizes field numeric values.

The adapter opens read-only with close-on-exec, reads an owned snapshot, then
closes the file descriptor before exposing the area. Maximum file size is
64 MiB; maximum field count is 128; numeric precision is limited by the scaled
int64 representation and at most 17 decimals. Close, reopen and error paths
release the snapshot. There is no locking or consistency guarantee against a
concurrent writer during the read. Malformed/unsupported input is rejected
strictly; this does not claim identical acceptance of malformed files by Harbour.

## Reproduce the same-source oracle gate

Build hbc from the current source as described in BUILDING.md. Separately build
an official Harbour checkout; the measured reference pin is
`694428e1c12f726675b19324d62167fa77d68185`. Then run on Linux x86-64 with GNU
binutils and Python 3:

```sh
python3 tests/dbf/check_oracle.py \
  --compiler ./hbc \
  --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 \
  --output /tmp/dbf-oracle-evidence
```

The output directory must not already exist. The script uses real Harbour to
create fixture DBFs, then compiles the same eight read-only `.prg` programs with
Harbour and hbc. It compares stdout, stderr and exit status exactly in normal
and instrumented hbc modes: 16 paired executions of eight programs. It keeps
sources, generated assembly, commands' channels and a result ledger under the
output directory. It does not download Harbour or modify repository fixtures.

The fixture builders use Harbour writes solely to create test inputs. This is
not evidence of write support in HarbourRust. The gate does not replace the
full regression manifest, negative tests, C bridge checks, sanitizer tests or
resource-lifetime tracing. v0.4.0's Linux manifest result is 1660/1661, with
inherited `t110` outstanding.

## Regenerate embedded assembly

`python3 tests/generate_linux_asm.py` regenerates `generated/hrdbf_linux.s`
from the C sources in `runtime/` using GCC and GNU binutils. The checked-in
recipe records compiler version, flags and assembly hash. Generation is a
development step; hbc embeds the assembly and does not invoke a C compiler
when compiling a user's program. Inspect regeneration diffs before committing;
different GCC versions need not emit identical assembly.

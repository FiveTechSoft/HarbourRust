# DBF fields by name: `alias->NAME`, `FIELD->NAME`, Harbour run-time errors

Builds on 92f5c7a, which admitted `dbUseArea(..., .F., .F.)` as an exclusive
read-write open and lowered undeclared identifiers of DBF programs to
`dbffieldref("name")`. Program from the user report (M_CLIE.DBF):

```harbour
PROCEDURE Main()
   DBUSEAREA(.T.,"DBFCDX","M_CLIE.DBF","CLIE",.F.,.F.)
   ? NOMBRE, EDAD, CLIE->NOMBRE
   DBCLOSEAREA()
RETURN
```

## What this adds

- **`alias->name`, `FIELD->name`, `_FIELD->name`:** parsed (`->` lexes as
  `-` `>`) into `dbffieldref(name[, ALIAS])`. `M->` and `MEMVAR->` are
  memvar syntax and keep their previous behaviour.
- **Harbour's run-time errors** instead of the adapter's own
  `hbc: DBF field not found ...` / `hbc: DBF no workarea is open` lines:
  - no workarea open, or no such field: `Error BASE/1003  Variable does not exist: NAME`
  - `alias->name` with an alias that is not one of the program's literal
    `dbUseArea` aliases, or with the area closed: `Error BASE/1002  Alias does not exist: ALIAS`
  - followed by the `Called from` frames and exit code 1, through the same
    terminal error writer (`hrm_fail`) as the macro evaluator.
- **Lookup:** `hrdbf_app_fieldpos` (runtime/hrdbf_fieldpos.c,
  generated/hrdbf_fieldpos.s) returns -1 (no area), 0 (no field) or the
  ordinal; the value is then read like `FieldGet`. The unit is OS-free and
  compiled with hbc's SysV ABI for every target, so the per-OS DBF blobs are
  unchanged. Regenerate with
  `HR_FIELDPOS_CC=<mingw gcc> python tests/generate_dbf_fieldpos_asm.py`.
  The adapter's `hrdbf_app_get_name` is no longer called; the pruner drops it.

## Verification

`tests/dbf/fields/check_fields.py` is a native-Windows differential gate.
Real Harbour writes the fixture table: 3 records with C, N, N(8,2), L and D
fields, one record blank-dated. Ten programs are built by Harbour and by
hbc and run in the same directory. Exit code and stderr are compared byte
for byte; stdout is compared after removing Harbour's interactive
`(Quit, Retry)` alert line, which the terminal-headless profile omits
([MACRO-ERROR-CONTRACT.md](MACRO-ERROR-CONTRACT.md)).

```
python tests/dbf/fields/check_fields.py --compiler hbc.exe \
  --harbour <harbour-3.2.0-win-mingw64> --mingw-bin <mingw64/bin>
```

The programs cover:
- a full skip loop including EOF blanks;
- alias and `FIELD->` spellings in mixed case;
- a local shadowing a field and field reads inside called functions;
- integer arithmetic and comparison on a numeric field;
- `Empty` and `ValType` on fields;
- each error case.

Result: 10/10 identical. A control run with the previous compiler fails
all 10. The gate checks that the fixture builder exits 0 and wrote 3
records. Its first version passed 10/10 against an empty table, because
`B` is a reserved area letter and the builder had failed.

## Limits

- **`shared=.T.` stays rejected** (92f5c7a's contract).
- **Single workarea, as before.** `alias->` is checked against the literal
  aliases of the program's `dbUseArea` calls, not against the alias the
  open area really has.
- **No memvar fallback.** Harbour tries a memvar when no field matches; hbc
  reports BASE/1003. A caller's PRIVATE read by bare name in a DBF program
  is therefore an error here.
- **No writes:** no field assignment, `REPLACE`, or `dbAppend`.
- **Values are the existing Dyn DBF values**, with their existing limits:
  - no string concatenation with a field (`"[" + NOMBRE + "]"` is rejected,
    exactly like `FieldGet(1)`);
  - decimal numeric fields print but do not take part in arithmetic.
- **Console trailing spaces.** Fixed on Windows by
  [WINDOWS-CONSOLE-SPACES-2026-11-16.md](WINDOWS-CONSOLE-SPACES-2026-11-16.md):
  a padded field at the end of a `?` line keeps its spaces, as in Harbour.
- **Linux.** DBF programs do not assemble for Linux with the internal
  assembler (`.rodata.str1.1` in generated/hrdbf_linux.s). This predates
  this change: the same error appears with `FieldGet` and the previous
  compiler.

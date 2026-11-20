# x4/x5: dbSetOrder, dbGoto and FCount on the native adapter

Differential gate against real Harbour 3.2 (mingw64), same contract as
`tests/dbf/fields/check_fields.py`: every program is compiled by real
Harbour and by hbc `--target=windows` and compared (exit code, stderr,
stdout after dropping Harbour's interactive alert line).

Fixture (`build_fixture.prg`, built by Harbour only): `goto_set.dbf` with
5 fields and 7 records whose KEY codes are deliberately shuffled, plus
`goto_set.ntx` (INDEX ON KEY), so record order and index order disagree.

Semantics measured against real Harbour (native Windows probes o1-o5):

- `dbGoto(n)`: physical record n, `Eof`/`Bof` .F., `Found()` reset; with
  the controlling order selected the index cursor is re-planted on record
  n's entry, so the following `dbSkip` follows the order. `n <= 0` or
  `n > LastRec()`: record `LastRec()+1` with BOTH `Eof` and `Bof` .T.,
  natural or indexed; the indexed cursor rests past the last entry.
- `dbSetOrder(0)` and any order number outside the one-entry bag:
  deselect (natural order, bag stays open, record pointer, `Eof`/`Bof`
  and `Found()` untouched). `dbSetOrder(1)`: select the open order and
  re-plant the index cursor on the current record's entry.
- `FCount()`: field count of the open area.
- `dbSeek` with the order deselected: Harbour raises DBFNTX/1201
  ("Workarea not indexed"); hbc prints its own fail-fast line
  (`hbc: DBF index seek requires an open index`) and exits 1. The
  messages differ, so that case is a registered difference and stays
  outside this gate.
- `dbSeek` with a Dyn character value (bare field read or a Dyn local,
  g06): byte-identical, including the index cursor after the seek. A
  non-character key value (e.g. a numeric field against the
  character-key index) is a clean typed failure in hbc
  (`hbc: DBF index seek expects a character key value`), while Harbour
  converts the number to its string form; registered difference.

Runtime: new `hrdbf_app_goto`, `hrdbf_app_fcount`, `hrdbf_app_ordselect`
in `runtime/hrdbf_app.c` (active-order flag; seek/top/bottom/skip fall
back to natural movement while the order is deselected). Blobs
regenerated with the pinned toolchains via the `dbf-blobs.yml`
workflow (Ubuntu 22.04 gcc 11.4, mingw-w64 gcc 10 posix).

Usage:

```
python tests/dbf/goto-setorder/check_goto_setorder.py \
  --compiler hbc.exe \
  --harbour <Harbour 3.2 mingw64 install dir> \
  --mingw-bin <MinGW-w64 bin dir>
```

# shared=.T. readonly=.T. opens

Two-process differential gate against real Harbour 3.2 (mingw64), native
Windows. Same build contract as `tests/dbf/cdx-autoopen`.

```
python tests/dbf/shared-readonly/check_shared_readonly.py --compiler hbc.exe \
  --harbour C:/harbour --mingw-bin C:/HarbourRust/tools/mingw/mingw64/bin
```

The fixture (`build_fixture.prg`, built by Harbour only) has `shr.dbf` (3
shuffled records, no index) and `shc.dbf` with its structural `shc.cdx`.
`harbour/` holds the Harbour-only processes: a holder that keeps `shr.dbf`
open shared or exclusive and can append on request, a shared read-write
writer, and an exclusive opener. The two sides synchronize through flag
files and through the reader's first output line (`opened`).

| scenario | what it pins |
|---|---|
| alone | `r1` without another process: identical |
| holder-S | `r1` beside a Harbour shared read-write holder: identical |
| holder-SA | the holder appended and committed a record before `r1` opens: identical |
| holder-SU | the holder appended without dbCommit/dbUnlock before `r1` opens: identical (both see a fourth, blank record) |
| bag-held | `r3` reads `shc.dbf` in natural order while a Harbour process holds the table and its structural bag shared: identical |
| reverse | while `r1` holds the table, a Harbour shared writer appends and a Harbour exclusive open is refused, whichever compiler built `r1` |
| append | registered: Harbour sees a record appended after its open, hbc reads its open-time snapshot |
| holder-X | registered: Harbour sets NetErr and continues, hbc aborts at the open with win32 error 32 |
| r2 | registered: Harbour uses the structural bag on a shared open, hbc refuses any index on a shared open |

Before this change hbc rejected `r1` and `r2` at compile time
(`shared=.F.` only). See `docs/DBF-WINDOWS-READONLY.md`.

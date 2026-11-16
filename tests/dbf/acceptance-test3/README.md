# Acceptance: Antonio's test3.prg (verbatim)

`test3.prg` here is byte-for-byte Antonio's program (Windows, G:\HARBOUR4):

- `DBUSEAREA(.T.,"DBFCDX","M_CLIE.DBF","CLIE",.F.,.F.)` (exclusive
  read-write open; sixth argument readonly=.F.),
- `? CLIENTE` (bare field-name access),
- `DBCLOSEAREA()`.

It MUST NOT be modified to pass (for example flipping readonly to .T.
would falsify the acceptance). It is covered by D1
(docs/DBF-WRITE-OPEN-D1.md): it compiles and runs correctly under hbc with
a `M_CLIE.DBF` in the current directory (a Harbour-built fixture with a
`CLIENTE` field; the field layout of Antonio's real file is his data). The
same-source Harbour oracle lane cannot run it without a `REQUEST DBFCDX`
line (Harbour registers DBFCDX only on request), so oracle equivalence of
the same operations is covered by tests/dbf/programs/open-rw.prg and
fieldref.prg. The final acceptance run is Antonio's, on native Windows,
with his own M_CLIE.DBF.

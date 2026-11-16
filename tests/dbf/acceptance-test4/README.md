# acceptance-test4: D2 native DBF write path

`test4.prg` exercises the native write surface HarbourRust lowers for DBF:
`REPLACE field WITH expr`, `ALIAS->field := expr`, `FieldPut(n, value)`,
`dbAppend()` and persistence across `dbCloseArea()` (close, reopen, verify).

Run it on a COPY of `../acceptance-test3/M_CLIE.DBF` (the anonymized fixture;
the real file never leaves the owner's machine):

    cp ../acceptance-test3/M_CLIE.DBF m_clie.dbf
    hbc test4.prg test4        # or --target=windows for the PE64
    ./test4

Expected stdout: `test4.linux.expected.txt`. Measured against Harbour 3.2
(hbmk2, DBFCDX) the resulting `m_clie.dbf` is BYTE-IDENTICAL to Harbour's own
output for the same program, including the append header flush (record count,
header date, production-index flag byte 28 cleared) and the 0x1A EOF marker.

Notes:
- `REPLACE LIMITE WITH CLIE->LIMITE + 1` uses integer field arithmetic
  (N(10,0)); decimal field arithmetic (`SALDO + 1` on an N(16,2)) is outside
  hbc's Dyn integer arithmetic in BOTH adapters (the --harbour-rdd shim has
  the same boundary) and waits for the Dyn float-widening increment.
- `CLIE->SALDO := 1001.05` stores a double literal through the Harbour-exact
  N formatter (shortest round-trip decimal, round half-away).
- Bare `NAME := expr` for an undeclared NAME stays a compile error (Harbour
  3.2 assigns a memvar there; hbc does not create memvars implicitly): write
  `FIELD->NAME := expr` or `ALIAS->NAME := expr`.

# acceptance-test5: D3 decimal Dyn arithmetic (+,-,*,/ widening)

`test5.prg` exercises Dyn->F64 widening in `+,-,*,/` over DBF decimal
fields on the native adapter: decimal+integer, integer+decimal,
decimal+decimal, decimal*float, division (always double, dec = SET
DECIMALS = 2), Harbour dec rules on print (max for +,-, sum for *),
operator precedence, chained Dyn arithmetic (a float-cell result
re-entering arithmetic), and store rounding through
`REPLACE ... WITH <decimal expr>`.

Run it on a COPY of `../acceptance-test3/M_CLIE.DBF` (the anonymized
fixture; the real file never leaves the owner's machine):

    cp ../acceptance-test3/M_CLIE.DBF m_clie.dbf
    hbc test5.prg test5        # or --target=windows for the PE64
    ./test5

Expected stdout: `test5.linux.expected.txt`. Measured against Harbour 3.2
(hbmk2, DBFCDX) the resulting `m_clie.dbf` is BYTE-IDENTICAL to Harbour's
own output for the same program (7 bytes changed: the two SALDO fields;
the header is untouched), and stdout matches token for token. The
`--harbour-rdd` shim build produces the same stdout and the same bytes.

Notes:
- Harbour's dec metadata rules measured for this increment: `+,-` take
  max(dec), `*` sums, `/` is always a double with dec = SET DECIMALS (2).
  An N(10,0) field (LIMITE) reads as an integer LONG: `LIMITE + 1` stays
  on the integer fast path and prints without decimals.
- Integer fast path: when both operands extract to i64 the runtime
  helper keeps the compiler's wrapping add/sub/imul semantics bit for
  bit. Division is ALWAYS widened to double (hb_vmDivide), even for
  integer operands.
- Division by a real zero (+-0.0) fails clean ("DBF arithmetic division
  by zero"); Harbour raises recoverable EG_ZERODIV (registered
  failure-mode difference, same class as the NIL dialog).
- Comparisons (=,<,>) against decimal fields or float cells stay
  rejected (DECIMAL_I64): next increment.
- `%` and `^` with Dyn operands keep the previous integer extraction.

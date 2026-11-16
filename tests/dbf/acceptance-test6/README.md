# acceptance-test6: D4 decimal comparisons (=, <>, <, >, <=, >=)

`test6.prg` exercises comparisons over DBF decimal fields and Dyn float
cells (D3 arithmetic results) on the native adapter: `=`, `<>`, `<`,
`>`, `<=`, `>=` between a decimal field and float/integer literals,
between two fields, between chained Dyn arithmetic results and
literals/fields, and inside mixed arithmetic expressions. Numerics
compare BY VALUE (Harbour `hb_vmEqual`/`hb_vmCompare` measured on real
Harbour 3.2: `SALDO = 1000.050` is `.T.` though the written decimals
differ; `LIMITE = 51000.0` is `.T.`).

Run it on a COPY of `../acceptance-test3/M_CLIE.DBF` (the anonymized
fixture; the real file never leaves the owner's machine):

    cp ../acceptance-test3/M_CLIE.DBF m_clie.dbf
    hbc test6.prg test6        # or --target=windows for the PE64
    ./test6

Expected stdout: `test6.linux.expected.txt` (20 logical tokens,
`.T.`/`.F.` one per line, token-identical to the Harbour 3.2 run).
Comparisons never write: the DBF stays byte-identical to the fixture
copy. The `--harbour-rdd` shim build produces the same stdout.

Notes:
- Widening: when both operands are numeric (i64-extractable or
  decimal/double) the runtime compares the double reads by value; the
  i64 x i64 fast path stays integer-exact. A numeric against a
  non-numeric payload keeps the previous clean typed failure (Harbour's
  BASE/1071/1073-1076 dialogs are the registered failure-mode
  difference). IEEE rule: NaN compares unequal.
- The compiler hooks route kind-5 Dyn float cells (D3 arithmetic
  results) to the same DBF comparison wrappers as field tags 11/12.
- Without DBF active, Dyn x float comparisons keep the registered
  compile-time rejection (63zc); `%`/`^` with Dyn operands are
  unchanged.

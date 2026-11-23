# Wide and large tables

Differential gate against real Harbour 3.2 (mingw64), same contract as
`tests/dbf/cdx-autoopen`.

```
python tests/dbf/wide-large/check_wide_large.py --compiler hbc.exe \
  --harbour C:/harbour --mingw-bin C:/HarbourRust/tools/mingw/mingw64/bin
```

The fixture (`build_fixture.prg`) is built by Harbour only:

| table | shape |
|---|---|
| `wide187.dbf` | 187 fields cycling C/N/D/L, 5 records (the issue #1 item master shape) |
| `wide2046.dbf` | 2046 one-byte fields, the most a DBF header holds (Harbour refuses 2047, measured) |
| `big.dbf` | 620000 records of 122 bytes, about 75.6 MB, over the former 64 MiB bound |

| program | what it pins |
|---|---|
| w1 | FCount, ordinal and named access to fields past 128, every type |
| w2 | first, middle and last of 2046 fields |
| b1 | LastRec, last record, a full scan summing N and counting L, a middle record |

Before this change hbc rejected all three tables at open ("more than 128
field descriptors", "exceeds the 64 MiB limit").

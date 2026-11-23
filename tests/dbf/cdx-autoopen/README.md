# Structural CDX autoopen

Differential gate against real Harbour 3.2 (mingw64), same contract as
`tests/dbf/goto-setorder/check_goto_setorder.py`. Every program is built by
Harbour and by hbc `--target=windows`, and the exit code, stderr and stdout
are compared.

```
python tests/dbf/cdx-autoopen/check_cdx_autoopen.py --compiler hbc.exe \
  --harbour C:/harbour --mingw-bin C:/HarbourRust/tools/mingw/mingw64/bin
```

The fixture is built by Harbour only. Its 3 records are shuffled, so natural
order and key order disagree.

| program | what it pins |
|---|---|
| a01 | the bag opens unselected (natural order); `dbSetOrder(1)` selects it, keeping the record; `dbSeek`; `dbSetOrder(0)` |
| a02 | `OrdListAdd()` of the structural bag selects it and goes top |
| a03 | production flag set, no `.cdx`: silent, natural order |
| a04 | `.cdx` present, flag cleared: Harbour still opens it |
| a05 | `dbSeek` hit and miss through the structural bag |

Before this change hbc matched only a03.

A readonly=.F. open with a structural bag is a registered difference, so it
is outside this gate. Harbour opens and maintains the bag. hbc fails with an
explicit message as soon as the order is used.

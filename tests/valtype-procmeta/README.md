# ValType metadata proof

Run from repository root with BASE/candidate built using identical flags:

```
python3 tests/valtype-procmeta/check.py --compiler /tmp/hbc-new --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/valtype-proof
```

Optional --wine /path/to/wine --wine-prefix /path/to/prefix adds PE. HB is real Harbour hbmk2, pinned in review to694428e1c12f726675b19324d62167fa77d68185. Wine is not native Windows.

Pure ValType calls classify string/I64/NIL and remove ONLY five nonzero line stores. ValType(QOut(ProcName())) and ValType(QOut(ProcLine())), plus user calls inside QOut, keep BASE assembly identical and exact Harbour output. QOut is an already admitted effectful ValType argument; direct arbitrary calls are not currently admitted and are NOT enabled by this change. Each case runs BASE/candidate normal/instrumented ELF/PE. Also run the full manifest.

Limits: metadata proof only, no ValType argument-shape/type-classification/runtime/admission/ABI change or timing claim. This is NOT usable Val. Recursive arguments/global fail-closed walk remain; unknown forms, Eval/macros/references and externs retain metadata. Aeval never safe. General owned TRY-error gaps remain.

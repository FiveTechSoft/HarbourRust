# Int metadata proof

Run from repository root with BASE/candidate built using identical flags:

```
python3 tests/int-procmeta/check.py --compiler /tmp/hbc-new --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/int-proof
```

Optional --wine /path/to/wine --wine-prefix /path/to/prefix adds PE. HB is real Harbour hbmk2, pinned in review to694428e1c12f726675b19324d62167fa77d68185. Wine is not native Windows.

Pure Int calls include positive/negative F64 and zero I64. Assembly must change ONLY by deleting five nonzero line stores. Nested Int(Int(ProcLine())) and Int(Len(ProcName())), plus user functions returning those values, keep BASE assembly identical. Each fixture runs exact fresh Harbour comparison against BASE/candidate normal/instrumented ELF/PE. Also run the full manifest.

Limits: static metadata proof only, no numeric conversion/width/nonfinite/admission/runtime/ABI change or timing claim. Arguments recurse and global fail-closed proof remains. Unknown forms, Eval/macros/references and externs retain metadata. Aeval never safe. General owned TRY-error gaps remain.

# Trim metadata proof

Run from repository root with BASE/candidate built using identical flags:

```
python3 tests/trim-procmeta/check.py --compiler /tmp/hbc-new --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/trim-proof
```

Optional --wine /path/to/wine --wine-prefix /path/to/prefix adds PE. HB is real Harbour hbmk2, pinned in review to694428e1c12f726675b19324d62167fa77d68185. Wine is not native Windows.

Pure Trim calls include trailing spaces, all-spaces and empty input. Assembly must change ONLY by deleting five nonzero line stores. Nested Trim(Trim(ProcName())) and Trim(Str(ProcLine())), plus user functions returning those stack results, keep BASE assembly identical. Each fixture runs exact fresh Harbour comparison against BASE/candidate normal/instrumented ELF/PE. Also run the full manifest.

Limits: static metadata proof only, no runtime/trim semantics/admission/ownership/ABI change or timing claim. Arguments recurse and the global fail-closed walk remains. Unknown forms, Eval/macros/references and externs retain metadata. Aeval must never be safe. General owned TRY-error gaps remain.

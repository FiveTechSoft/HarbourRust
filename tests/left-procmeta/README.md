# Left metadata proof

Run from repository root with BASE and candidate built with identical flags:

```
python3 tests/left-procmeta/check.py --compiler /tmp/hbc-new --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/left-proof
```

Optional --wine /path/to/wine --wine-prefix /path/to/prefix adds PE execution. HB is real Harbour hbmk2, pinned in review to694428e1c12f726675b19324d62167fa77d68185. Wine is not native Windows.

Pure Left calls include zero count and empty input; assembly must change ONLY by deleting five nonzero line stores. Nested Left(ProcName(),...) and ProcLine in the later count argument, plus user calls returning those values, keep BASE assembly identical. Every fixture runs exact-output checks against real Harbour for BASE and candidate, normal/instrumented ELF/PE. Also run the full manifest.

Limits: metadata proof only, no runtime/ownership/admission/ABI change or timing claim. Recursive arguments and global fail-closed proof remain; unknown forms, Eval/macros/references and externs retain metadata. Aeval must never be marked safe. General owned TRY-error gaps remain.

# At metadata proof

Run from repository root with BASE/candidate built using identical flags:

```
python3 tests/at-procmeta/check.py --compiler /tmp/hbc-new --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/at-proof
```

Optional --wine /path/to/wine --wine-prefix /path/to/prefix adds PE. HB is real Harbour hbmk2, pinned in review to694428e1c12f726675b19324d62167fa77d68185. Wine is not native Windows.

Pure At fixtures(found,not-found,empty) remove ONLY five nonzero line stores. ProcName in the second string argument, Str(ProcLine()) in the first, and user functions returning those values keep BASE assembly identical. Every fixture runs exact-output comparison against fresh Harbour for BASE/candidate normal/instrumented ELF/PE. Also run the full manifest.

Limits: static metadata proof only. No runtime/search semantics, admission, ownership, allocator or ABI change, and no timing claim. Arguments always recurse and the global fail-closed walk remains. Unknown forms, Eval/macros/references and externs retain metadata. Aeval must never be marked safe. General owned TRY-error gaps remain.

# Lower metadata proof

Run from repository root with BASE and candidate built using identical flags:

```
python3 tests/lower-procmeta/check.py --compiler /tmp/hbc-new --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/upper-proof
```

Optional --wine /path/to/wine --wine-prefix /path/to/prefix adds PE. HB is real Harbour hbmk2, pinned in review to694428e1c12f726675b19324d62167fa77d68185. Wine is not native Windows.

Pure Lower calls include empty string: generated assembly must change ONLY by deleting five nonzero line stores. Nested Lower(ProcName()) and Lower(Str(ProcLine())), plus user functions returning stack introspection results, must keep BASE assembly identical. Every case runs against fresh Harbour output on BASE and candidate, normal/instrumented, ELF/PE. Do not remove the empty case: it found the published runtime bug fixed separately in f8685687.

Also run tests/case-empty/check.py and the full manifest. Only metadata proof changes here; no runtime mapping, admission, ownership or ABI expansion. No speedup claim. Unknown forms, Eval/macros/references and externs remain fail-closed. Aeval must never enter the safe list because it executes user code. General owned TRY-error cleanup gaps remain.

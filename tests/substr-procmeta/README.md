# SubStr procedure metadata proof

Add SubStr to the known-safe builtin list in `proc_metadata_needed`. SubStr itself does not read ProcName/ProcLine or invoke user code implicitly. Its argument expressions are still traversed recursively, and the existing program-wide walk still examines user-defined functions. Thus nested ProcName/ProcLine, including through explicit user calls, keep line metadata enabled.

Run from the repository root after building both BASE and candidate with identical rustc flags:

```
python3 tests/substr-procmeta/check.py --compiler /tmp/hbc-new --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/substr-procmeta
```

Optional `--wine /path/to/wine --wine-prefix /path/to/prefix` adds PE execution. Wine is not native Windows. HB must be the real Harbour hbmk2, not the candidate. The review pins Harbour to694428e1c12f726675b19324d62167fa77d68185.

The pure2/3-argument and negative-start fixture checks exact Harbour output for BASE and candidate, normal and instrumented. Its emitted assembly differs ONLY by deleting five nonzero procedure-line stores. The direct introspection fixture nests ProcName inside another SubStr and uses ProcLine in a later argument. The user-call fixture obtains ProcName/ProcLine through user functions. Those two controls require candidate and BASE assembly to remain byte-for-byte identical, in addition to exact oracle output.

Also run `tests/substr/check.py` and the full existing manifest. No benchmark speedup is claimed by this proof-only micro-change. Diagnostic trace text, trace linking/unlinking and runtime error behavior remain present; this only allows the existing line-store elision when no stack introspection is found. Unknown AST kinds, builtins, function references, Eval/macros and externs retain the existing fail-closed treatment.

Limits: no new string admission, numeric coercion, allocator, F64 or ABI change. This does not fix general owned TRY-error cleanup gaps or extend the list to other builtins.

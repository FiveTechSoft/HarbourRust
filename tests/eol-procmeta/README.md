# hb_eol metadata proof

Run from repository root:

```
python3 tests/eol-procmeta/check.py --compiler /tmp/hbc-new --baseline /tmp/hbc-base --hbmk2 "$HB" --output /tmp/eol-proof
```

Optional --wine /path/to/wine --wine-prefix /path/to/prefix adds PE. HB is real Linux Harbour hbmk2, pinned in review to694428e1c12f726675b19324d62167fa77d68185. Linux compares fresh Harbour bytes exactly. PE checks an explicit target-specific CRLF expectation: it is NOT a Windows Harbour oracle. hb_eol returns LF on Linux, CRLF on Windows in current source; no behavior change here. Wine is not native Windows.

Pure calls Len/Asc/OutStd(hb_eol()) remove ONLY five nonzero line stores. hb_eol has no admitted arguments, so recursion cannot be tested inside its arguments; controls instead combine it with direct ProcName/ProcLine or explicit user functions that introspect. Those controls must keep BASE assembly identical, with exact platform-appropriate output. Each fixture runs BASE/candidate normal/instrumented ELF/PE. Also run full manifest.

Limits: metadata proof only, no EOL/platform semantics/admission/runtime/ABI change or measured speedup. Unknown forms, Eval/macros/references and externs stay fail-closed. Aeval never safe. General owned TRY-error gaps remain.

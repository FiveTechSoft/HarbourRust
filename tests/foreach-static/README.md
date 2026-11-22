# Static-array FOR EACH regressions

The hidden collection pair occupies 16 frame bytes in both `layout_locals`
and `cg_stmts`, including when iteration reads the existing stack-array slot.
Static iteration must not overwrite that owner's offset with the hidden slot.
Later local offsets and the destructor slot table must agree.

Run on native Linux or Windows:

```
python tests/foreach-static/check.py --compiler ./hbc
```

Use `./hbc.exe` on Windows. The runner checks exit status, raw stdout and
empty stderr, with instrumentation both off and on. It executes the four
former negative cases, the original feature fixture, and three owner-lifetime
regressions. Expected Windows bytes are CRLF translations of the verified
Linux outputs; native Windows execution is still required to validate them.

- `owned_after`: three sequential loops followed by owned strings, a string
  array and nested decoded JSON. On unpatched 51e2f686 this prints values and
  then crashes during cleanup, before `cleanup complete`.
- `owned_inside_early`: owner declared inside a loop, owner declared after a
  loop, scalar 123, sequential loops and early RETURN. Unpatched 51e2f686
  crashes after TAIL, before INSIDE/done.
- `owned_exit_loop`: owned locals with EXIT and LOOP, followed by more owned
  locals and function cleanup.

The former negatives keep their historical filenames but are positive
manifest entries. Their pins were checked against actual Linux execution.
The full Mac inventory is 1298 manifest rows plus 57 additional programs,
1355 total, with the existing target-scoped rejection unchanged.

The JSON escape fixture's e-acute row is restored byte-for-byte from
76d4c63a. Its old compatibility output is preserved, not rewritten to make
the new decoder pass. `tests/json-safety/expected/escapes_utf8.*.out` remains
the separate UTF-8 runtime contract. Restoring that old row does not claim
that the full historical JSON compatibility fixture passes.

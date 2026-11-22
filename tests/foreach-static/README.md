# FOR EACH over fixed-size stack arrays

`for each x in a` with `a` a fixed-size stack array (`local a := {1,2,3}`,
the all-integer literal type `Arr(k)`): the checker lifts the old
blanket rejection (the codegen's static path existed half-wired) and the
loop variable materializes a plain tag-0 i64 pair per iteration, so the
body may store/accumulate it (`n := n + x`) - the borrowed-string
observation-only rule stays for the dynamic collections. In place: the
collection iterates the OWNER's own frame slot (no snapshot), the loop
end compares against the static length, the element address is `lea`
of the inline cell (they run DOWNWARD: cell k lives at `off - 8*k`).
All-strings literals type DArrS (the dynamic string path unchanged);
an INLINE literal collection (`for each x in {1,2,3}`) keeps the
"assign the expression to a variable first" rejection.

`expected/foreach_static.windows.out` is the original fixture recorded as
Harbour 3.2 output (hbmk2 -comp=mingw64 -gtcgi, native Windows 11); its Linux
counterpart has the same bytes with LF line ends. Byte-exact (10 pins).
This provenance applies only to that original fixture. The four converted
t976-t979 Windows pins and the three new owner-regression Windows pins are
CRLF translations of verified Linux output, not measurements of Harbour.

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
regressions. New regression Windows bytes are CRLF translations of the verified
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

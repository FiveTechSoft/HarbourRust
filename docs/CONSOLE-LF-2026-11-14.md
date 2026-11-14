# Formatted console LF boundaries, 14 November 2026

Review candidate, not published. Base: `7d20db39627371abd2dbab02176acc165a25d9ca`.
Independent MIT assembly, measured with executable Harbour at pin
`694428e1c12f726675b19324d62167fa77d68185`; no Harbour implementation source
is translated or imported.

`hbc_pstrt` now processes formatted string output by LF-delimited segments.
A visible prefix flushes earlier held spaces because they are interior. At
LF, trailing segment spaces and an immediately preceding CR are dropped,
then the existing console newline is emitted. The final segment retains the
existing trim-and-hold rule. Source bytes and ownership do not change.
Raw OutStd/OutErr, argument evaluation order and diagnostics stay unchanged.

Nine permanent output-only sources cover LF, CRLF, internal LF with visible
prefixes, empty lines, trailing LF, spaces following LF and raw output. Each
has freshly observed Harbour GTSTD stdout and empty stderr. Standalone CR,
TAB and CRLF split across separate rendered strings are outside this bounded
contract. No general cursor or terminal implementation is claimed. The old
LF behavior is intentionally replaced, not normalized away in the test harness.

The exact console-only source/module set passes the old Linux instrumented
manifest 1661/1661 and the nine probes in normal/instrumented Linux/Wine,
36/36 channel comparisons. Windows checks use Linux oracle contract bytes
and establish candidate consistency, not a native Windows Harbour oracle.
The existing console newline is LF on both targets. `hb_eol()` still returns
CRLF on Windows; formatted CRLF now goes through the console LF boundary.

An initial label `.Lpseg_scan_start` collided with an existing textual `_start:`
startup insertion. Owned-string controls t1549/t1551 caught it. The retained
name `.Lpseg_begin` avoids the collision; the failed run is preserved and is
not counted as final evidence. New helper scratch r8 is saved/restored.

Reproduce after building the reviewed compiler:

```
python3 tools/check_procmeta.py --compiler ./hbc --output /tmp/console-lf \
  --console-only
```

Add `--wine /path/to/wine --wine-prefix /path/to/prefix` for cross-target
candidate checks. No compatibility coverage count increases with this patch
alone: ProcName ancestor support is a separate reviewed increment.

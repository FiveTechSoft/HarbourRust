# Windows console: trailing spaces and embedded LF as Harbour GTCGI writes them

hbc's console output holds trailing spaces (string tails and item
separators) in `hbc_pending` and drops them at a `?` newline, at an
`OutStd` write and at program exit. That rule was measured against the
Linux oracle ([BASELINE-2026-11-13.md](BASELINE-2026-11-13.md)) and stays
unchanged on Linux.

Harbour 3.2 on Windows (GTCGI, the oracle the Windows fixtures use) writes
every separator and trailing space, and writes a formatted string's bytes
as they are. So on Windows `? "a  "` printed `a` with hbc and `a  ` with
Harbour, and `? "e  " + Chr(10) + "f"` printed `e\r\nf` with hbc and
`e  \nf` with Harbour. A character field at the end of a `?` line (DBF
fields are space-padded) showed the difference.

## Change (Windows target only)

- `?` newline: the hold is written (`hbc_pflush`) instead of dropped.
- Raw stdout writes (`OutStd`): the hold is written first, so the bytes
  keep their order.
- Normal exit, `hbc_panic_exit` and the terminal error writer
  (`hrm_contract_exit`, macro and DBF errors) write the hold before
  `ExitProcess`.
- `hbc_pstrt` (Windows copy in `WIN_HELPERS`): an LF inside a formatted
  string is written raw, with the spaces before it and any earlier hold;
  only the tail after the last LF is held (and written at the next output).

## Verification

- Four probe programs compared with real Harbour 3.2 (stdout, stderr,
  exit code) are byte-identical. They cover `?`, `??`, `QOut`, `QQOut`,
  `OutStd`, `OutErr`, Dyn strings, array cells, numbers and logicals,
  empty and all-space items, embedded LF, and a run-time error after a
  line ending in spaces.
- Full native Windows battery: 35 rows changed. Each one was rebuilt with
  real Harbour and run next to the new hbc build in the same directory.
  - 31 are byte-identical to Harbour.
  - The other 4 differ from Harbour only in older, unrelated ways:
    - t1551: NUL prints as `.`;
    - datefns: `Day()` width;
    - t1657/t1658: Harbour cannot build them (no MAIN procedure).
  - For those 4, old and new hbc output differ only in the restored
    spaces.
- The 35 Windows expectation files were regenerated from the new output.
  `procmeta/newline-oracle/raw.prg` became a `streams2` row with its own
  `raw.windows.stdout` (marked `-text`), so its Linux file is untouched.
  The full manifest then passes: 1720 pass, 0 fail, 23 skip.
- `tests/run_battery.sh` (Linux + Wine runner) gained the `streams2` and
  `posx2` kinds the manifest already used. This host has no Linux or Wine,
  so that runner was syntax-checked only, not run.

## Limits

- NUL bytes in `?` output still print as `.` (GTSTD presentation); GTCGI on
  Windows writes them raw (t1551).
- Mixed `??`/`OutStd` ordering follows the order of the writes; no other
  buffering rule is modelled.

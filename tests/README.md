# Test suites

`manifest.txt` is the main regression manifest (`pos`, `posx`, `pos2`,
`streams`, `neg`). Three runners consume it:

- `run_battery.sh`: Linux + Wine, `--instrument` builds, external `as`/`ld`.
- `run_battery_win.sh`: native Windows. MinGW binutils by default;
  `HBC_INTERNAL_PE=1` compiles with hbc's internal PE writer, and
  `GEN_DIR`/`MANIFEST_FILE` isolate a run from other jobs. CurDir and class
  sources are skipped on Windows by design. Stream and `pos2` cases report
  `PASS*` only when the raw comparison failed and CR normalization was
  required.
- `run_battery_win_compile.ps1`: front-end-only Windows gate; checks compile
  acceptance and named negative messages without assembling, linking,
  executing or requiring MinGW, Rust, bash or Wine.

Text expectations are stored with LF (`.gitattributes`).
`t1041_longstr_linux.out`, `t1041_longstr_windows.out` and
`t1576_text_cr.prg` intentionally contain CR bytes and are marked `-text`.

Additional suites and gates:

- `classes/`, `threads/`, `dbf/`, `ntx/`, `cdx/`: differential gates against
  real Harbour; each `check_oracle.py` takes `--compiler` and `--hbmk2`
  (threads and classes are Linux-only; DBF/NTX/CDX cover the documented
  read-only scopes).
- `arena/check_regress.py`: scope-arena regression gate; `--compiler`,
  optional `--target windows --wine`.
- `escape/run.sh`: I1 escape-classification gate; `HBC` selects the compiler.
- `procmeta/` and `hash-ownership/`: exact stdout/stderr fixtures used by
  `tools/check_procmeta.py` and `tools/check_hash_ownership.py`
  (`--compiler`, `--output`, optional `--wine`).
- `oracles/`, `probes/`, `probes/legacy-hk/`: Harbour oracle sources and
  historical probes; see their README files and `3-MANIFEST.md`.

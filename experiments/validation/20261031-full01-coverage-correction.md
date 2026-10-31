# full01 coverage correction and manifest desync postmortem (2026-10-31)

CORRECTION of the full01 claim and of the 676db8d4 commit message
(published; history is never rewritten, so the correction lives here).

## What full01 actually ran

RUNID=ains1b-stepb-full01 ran the HISTORICAL 243209ae manifest
(sha 25135c6a, 1466 cases: 894 pos / 497 neg / 73 posx / 1 pos2 /
1 streams) against the FINAL cd62b1ec sources (ad8a47dd) and binary
(c68e6ed2). Result: 1466/1466 cases + 5/5 scripts green, 1471 PASS,
global rc 1 caused solely by the unparseable `#` block-header line
(runner has no '#' case). It did NOT run the cd62b1ec manifest
(d1a52290, 1470 cases incl. t1474-t1477). Anchor equality of src/bin
at start/end proved immutability during the run; it did NOT prove the
selected manifest was HEAD - the manifest copy was stale from the
start.

## Chronology correction

The 676db8d4 message said the 4 extra neg tests (t1474-t1477) were
"added after full01's manifest". FALSE: d5aefc35 (t1474/75) and
cd62b1ec (t1476/77) precede full01 (18:59). The tests were missing
from the run because the build scratch copy of the manifest was never
updated, not because of any later addition. Process failure, not a
timeline of work.

## Cause

Two manifest copies exist: the publishing clone (harbourrust, updated
with t1474-t1477 in d5/cd62) and the build/probe scratch (hr-aeval),
where run_battery.sh executes with MANIFEST_FILE defaulting to
hr-aeval/tests/manifest.txt. The (b) fix commits updated only the
publishing copy. Focused runs used /tmp mini-manifests extracted from
the publishing copy, so they covered the new neg tests by name; the
default-manifest run silently used the stale scratch copy.

## Composite coverage of step (b) at cd62b1ec (honest description)

- full01: 1466 historical-manifest cases + 5 scripts green, both
  targets, final cd62 binary/src; rc 1 explained (comment line).
- t1474-t1477 (the 4 neg tests added by the idx/borrow fixes): verified
  manually, compile-time rejection with the named error on BOTH
  targets; not yet in any battery run.
- Focused batteries on the final binary: 54-case view manifest,
  13-case output-guard, 36-case borrow manifest (incl. t412), all
  green Linux+Wine.
- Corrected manifest f75b8137 (1470 cases, parsing-clean, no '#'
  lines) exists at 676db8d4; it has NOT been run as a whole and no
  cosmetic rerun is planned.

## Prevention

hr-aeval/tests/manifest.txt synced to the HEAD manifest (f75b8137)
immediately after the audit finding. Future evidence reports must
state the manifest sha AND its commit provenance, not only equality of
anchors over time.

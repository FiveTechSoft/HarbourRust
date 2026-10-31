# Reproducible audit: abandoned a124d582 vs published 5085ee94 (31Oct)

## Classified diff (8530 paths total)

| status | category | count |
|--------|----------|-------|
| D | gen/ (battery build/run artifacts) | 6040 |
| D | tools/mingw/ (committed toolchain binaries) | 2488 |
| D | hbc (committed compiler binary) | 1 |
| M | .gitignore (artifact exclusions added) | 1 |

Every path outside those four categories is byte-identical between the two
commits. The full `git diff --name-status` list is
audit-diff-a124d582-5085ee94.txt in this directory. (An earlier figure of
6041 gen/ files was off by one; the classified listing above is the
authoritative count.)

## Exact commands (run in the harbourrust clone)

    git diff --name-status a124d582 5085ee94
    git rev-parse a124d58:src/hbc.rs 5085ee94:src/hbc.rs
    # both = a977ed86f3dcda92a736f463335abd77f023381f
    git rev-parse a124d58:tests/manifest.txt 5085ee94:tests/manifest.txt
    # both = e8f1ff8b4dc769a5a5b875992e8895044356e39b
    git cat-file -p a124d58 | head -5
    # tree 9f6315cd15a5275ccef92d45742f0e492bc5f94e, parent 6e65a2e1e62f...
    git cat-file -p 5085ee94 | head -5
    # tree 0800ca34f0063659e74d5aef4f27ab120734f3a7, same parent
    git bundle create a124d58-abandoned.inc.bundle refs/recovery/a124d58 --not 6e65a2e1e62f82cc2279cc427d46d671d3c0ef20
    sha256sum a124d58-abandoned.inc.bundle
    # 74c60a0db78b0f3a8384000ad2076051d969b6aafdee88af8e834c091a446ba3

## Binary reproducibility

    rustc --version        # rustc 1.99.1 (58cf8f9c3 2026-10-13)
    git checkout 5085ee94 -- src/hbc.rs   # blob a977ed86...
    rustc -O src/hbc.rs -o hbc
    sha256sum hbc
    # must equal 76a05dc409a3c88ec70943b69dbd355a5cb136584fed74dfde4e81cd40ed96aa
    # (verified 31Oct 16:57 CET, bit-exact)

## Tests/scripts used for the identity claims

- tests/run_battery.sh at 5085ee94 (blob e8f1ff8b... manifest, 1424 cases):
  the 31Oct 16:53 green run (t528 double-failure incident preserved under
  t528-incident/). The run's compiler binary hash was NOT captured at run
  time; the binary/source binding above is a post-hoc reconstruction
  (rebuild verified 16:57, re-verified with the full src tree 17:29), not a
  run-time anchor. This limitation is permanent for that run.
- The equivalence check of 16:57 compared hr-aeval working-copy files
  byte-for-byte against `git show 5085ee94:<path>` for src/hbc.rs,
  tests/manifest.txt and the 7 touched test files.

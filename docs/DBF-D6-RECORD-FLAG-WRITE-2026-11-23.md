# DBF D6: record-state write surface (dbDelete / dbRecall / dbCommit) — design proposal

Status: **design proposal, not implemented, not measured, not published**
(2026-11-23). No builtin below is wired into the native adapter by this
document. Every Harbour semantic it defines is to be confirmed against the
oracle before the increment is published, exactly as D1–D5 were. See
[DBF write and decimals](../README.md#active-development), the
[D1 record](DBF-WRITE-OPEN-D1.md), acceptance programs
[tests/dbf/acceptance-test4..7](../tests/dbf/acceptance-test4/README.md), and
the [x4/x5 goto/setorder gate](../tests/dbf/goto-setorder/README.md).

## What is already built (verified and in main)

Native adapter (Linux + Windows x86-64, one workarea):

- exclusive read-write open (`readonly=.F.`, `shared=.F.`), writes via
  `hrdbf_file_write_record` (pwrite64), close-flush; no index propagation
- field writes: `REPLACE ...` / `ALIAS->field :=` / `FieldPut` / `dbAppend`
  (D2), decimal `+ - * /` (D3), decimal comparisons (D4), `%` and `^` (D5)
- navigation/order: `dbGoto`, `dbGoTop`, `dbGoBottom`, `dbSetOrder`, `FCount`
- the delete-flag reader `hrdbf_deleted` (native blob) and the delete-flag
  encoder `hrdbf_write_deleted` (port of OpenADS `set_record_deleted`)

The delete-flag encoder and the `Deleted()` reader exist in the runtime, but
the language-level `dbDelete()`/`dbRecall()` are compile-rejected on the
native adapter today (`"dbDelete" is outside this DBF increment"`). The
enabled-but-unimplemented work is thin here.

## Proposed D6 scope

Two admitted operations and one contract decision, each small and reviewable:

### 1. `dbDelete()` — mark the current record deleted

- `hrdbf_write_deleted(rec, 1)` on the current record's delete byte
  (`rec[0] = '*'`), then `hrdbf_file_write_record` (same immediate commit
  contract as FieldPut/REPLACE). `Deleted()` reports `.T.` (the reader is
  already wired).
- Same rules as every write in this increment: open with `readonly=.F.`,
  no open index (writes with an open index stay rejected; index propagation
  is D7), a record must be positioned (`recno <= LastRec()`), fail fast with
  a named message in the same style as `hrdbf_app_require_writable` — never
  silent.
- Reopen contract: a marked record stays marked (the flag is `'*'` in the
  file). Harbour's oracle behavior for `Deleted()`/`dbDelete()`/`dbRecall()`
  over reopen must be measured before publication; this doc does not assert
  it.

### 2. `dbRecall()` — unmark the current record deleted

- `hrdbf_write_deleted(rec, 0)` (`rec[0] = ' '`) + same immediate commit
  path. Identical rules to (1).
- Same oracle obligation.

### 3. `dbCommit()` — arity check + documented no-op, or rejected — decide with the oracle

- `hrdbf_app_*` writes are already synchronous (field/record writes hit the
  OS immediately; `dbCloseArea` is the only header-flush point).
- Two shapes are possible: (a) admit it as a named no-op that validates
  arity (zero arguments, everything else rejected), with a doc line saying
  "writes commit immediately, `dbCommit` has no effect"; or (b) keep it
  rejected as today. The choice is **not** made here: it needs a measured
  oracle row for `dbCommit` on a writable-exclusive open before the
  decision is defensible. Until then the native adapter keeps its current
  compile-time rejection with the named message.

### Out of scope for D6 (explicitly, for later increments)

- **Index updates** (D7): writes currently fail closed under an open index
  (`hbc: DBF field write with an open index is outside this increment`).
  Harbour updates the index on write; hbc does not. D7 would define the
  admitted write-with-index subset (single tag, one workarea), the
  consistency contract (index re-read at close vs maintained in place),
  and the error modes. Not in D6.
- **ordCreate**: needs index codegen and oracle measurement — not in D6.
- **Record/file locking on a shared open** (D8): `shared=.T.` +
  `readonly=.F.` stays a compile-time error; Harbour's shared lock protocol
  remains unmeasured on this path. Not in D6.
- **Multi-field / scoped REPLACE** and any multi-area (alias-selection) work
  — unrelated to D6.

## Files the increment would touch (shape, not a diff)

```
runtime/hrdbf_app.c           # hrdbf_app_delete/hrdbf_app_recall (same pattern as fieldput's immediate commit)
runtime/hrdbf_file_{linux,windows}.c
                             # (only if a delete-flag write needs a distinct entry point — same as field write otherwise)
generated/hrdbf_{linux,windows}.s
                             # regenerated from the same helpers (same recipe/toolchains, dbf-blobs.yml)
src/hbc.rs                   # allow dbDelete/dbRecall at the checker; delete/recall codegen arm in the DBF call family
tests/dbf/acceptance-test4..7 + new tests/dbf/delete-recall/*
                             # oracle gate: dbDelete/dbRecall + Deleted() + reopen persistence, same-source vs Harbour 3.2
docs/DBF-D6-WRITE-RECORD-FLAG-2026-11-23.md  # this doc; the final record moves here or to a sibling once measured
```

## Evidence gates required before publication

1. Same-source oracle gate: a new acceptance program (copy of
   `tests/dbf/acceptance-test4/test4.prg`'s fixture, new file with
   dbDelete/dbRecall + `Deleted()` + reopen) run under real Harbour 3.2 and
   hbc, stdout/stderr/rc byte-identical, normal and instrumented
   modes — alongside the existing D2/D3/D4/D5 acceptance programs, which
   must keep passing.
2. Named failure gates: `dbDelete` on a read-only open, with an open index,
   or with no record positioned — each fails with its own named message,
   never a silent partial write.
3. Reopen gate: a marked record stays marked after close/reopen (the flag
   persists in the file).
4. No-regression gate: the x4/x5 differential gate and the full D2–D5
   acceptance suite unchanged; evidence pairs the new program with the
   existing ones in the same ledger.
5. Blob regeneration reproduces `generated/hrdbf_*.s` hashes with the
   pinned toolchain; the oracle source and wrapper hashes stay in the
   recipe.
6. Independent review by a second party before publication; the
   publication owner keeps the final hash check (per repo practice).

## Why it is not done here

No Harbour oracle, no Wine, no x86-64 execution host, and no MinGW recipe
toolchain exist in this session. The D6 machinery is small and visible —
the encoder and reader already exist — but its semantics (reopen behavior,
`dbCommit`, error ordering) are a property of the oracle, not of the code.
Wiring the calls today would publish a claim the oracle has never confirmed.
The next session with an oracle moves straight from this document to the
implement.

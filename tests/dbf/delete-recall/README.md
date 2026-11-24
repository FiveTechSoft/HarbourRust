# DBF D6: delete-flag writes (dbDelete / dbRecall / dbCommit)

Differential gate: same-source programs compiled and run under official
Harbour 3.2 (mingw64, native Windows) and hbc, stdout/stderr/rc
byte-identical after stripping Harbour's trailing alert suffix and
normalising CRLF to LF (same pattern as ../goto-setorder).

Oracle-measured (2026-11-24, probes d6_sem/d6_eof/d6_ro/d6_commit, native
Windows 11, Harbour 3.2 r2104281802 -gtcgi):

- `dbDelete` marks rec[0]='*' on the current record, `dbRecall` marks ' ';
  immediate commit, same contract as the D2 field writes; `Deleted()`
  reports through the pre-existing reader (hrdbf_deleted).
- A marked record persists over close/reopen; a recalled record stays
  unmarked (d02_reopen_persist, both directions).
- delete on an already-deleted record stays marked; recall on a clean
  record stays clean (d01 tail).
- At EOF (recno > LastRec) `dbDelete`/`dbRecall` are silent no-ops: no
  error, no flag change, RecNo stays LastRec()+1 (d03_eof_noop) - this
  overrides the design doc's "record must be positioned" hypothesis.
- `dbCommit()` and `dbCommit(1)` on a writable exclusive open: accepted,
  no output; admitted as a named no-op (writes are already synchronous).
- A readonly open: the oracle raises DBFNTX/1025 "Write not allowed" at a
  positioned record; hbc fails fast at runtime with its own named line
  (r01). An open index stays a runtime named rejection (r02; index
  propagation is D7). Arity/type errors are compile-time named
  rejections (r03-r05).

One measured oddity kept out of the gate: alias "D" is not released by
the oracle's dbCloseArea after a delete (DBCMD/1011 "Alias already in
use" on reopen, while alias "T"/"X" reopen fine); hbc frees it. The
programs use alias "X".

Run: `python tests/dbf/delete-recall/check_delete_recall.py --compiler ./hbc
--harbour C:/harbour --mingw-bin <mingw64 bin>` (Linux/Wine and the
--external-as/instrumented matrix are unverified here; the fixture
builder needs a real Harbour: hbc has no dbCreate).

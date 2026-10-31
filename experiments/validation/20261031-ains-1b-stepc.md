# ains 1b step (c): hb_ntos over Dyn cell + IIF immediate-output union (2026-10-31)

Scope (approved contract): immediate output only, IIF branch cleanup,
borrowed never freed, hb_ntos tag-0 guard. No alias/RC/float work.
Checker+cg only; hbc_dyn_to_i64 (verified tag-0 guard, other tags ->
clean registered type error) already existed in both runtimes.

Change: hb_ntos accepts a Dyn argument (array/view cell) and returns an
owned string; cg emits hbc_dyn_to_i64 before the integer->text helper.
The existing 63zf IIF owned-string unification (borrowed arm cloned on
its taken path only) plus the existing print-path temp free turned out
to provide the full cleanup; the memory matrix below verifies that
claim rather than assuming it (main 19:06).

Validation (hr-aeval build, src identical to this commit):
- Oracle byte-exact (Harbour @694428e1, hbmk2 -gtstd): t1478
  `1,C,U,L,`, t1479 `C`. (Fixture separator is "," because literal
  space items hit the KNOWN pre-existing trim divergence, registered at
  step (b); not a (c) effect.)
- Memory matrix, hb_memcheck()==0 AND value prefix byte-exact vs
  oracle: loop (t1478 shape with instrumentation), recursion through
  nested views (t1486), two output calls in one body (t1487), nested
  iif temps (t1485), 1000 alternating owned/borrowed-arm iterations
  over an 8-cell mixed array (t1488, pos2 exact bytes both targets).
- Guards (clean registered errors, rc 1): hb_ntos over NIL / logical /
  tag-6 array cells (t1482-t1484). NOTE: the shared type-error helper
  prints "NIL used as a number" for ALL tags - registered message
  inaccuracy, not a compat claim; Harbour raises a dialog there
  (headless-unprobeable), so these pin OUR registered failure mode.
- Conservative rejections pinned (Harbour runs rc 0; registered
  divergence, t1465 family): iif arm returning a raw cell
  (t1480), iif union stored in a local / non-immediate consumption
  (t1481).
- Regression: 54-case view + 13-case output-guard + 36-case borrow
  batteries ALL GREEN Linux+Wine on the same binary
  (RUNID=ains1b-stepc-reg01/og01/borrow01); the 11-test step (c) block
  ALL GREEN both targets (RUNID=ains1b-stepc-block01).

Run anchors in probes/ains1b-stepc-impl01 (src/bin shas at start; log
raw). No LLVM suite. `str` unchanged (still I64-only). Step (d) (the
unadapted ains original) NOT started; aDump additionally needs the
trim-divergence resolution for byte-exactness.

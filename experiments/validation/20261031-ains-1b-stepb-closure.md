# ains 1b step (b): BOUNDED closure with composite validation (2026-10-31)

This is NOT a "final 1470-case suite ALL GREEN" claim. Step (b) closes
on COMPOSITE evidence, audited independently (full01-independent-audit):

- Independent reviews: 243209ae (1 blocker found: subview index
  consume/mutate), fixed in d5aefc35; recheck favorable; cd62b1ec
  recheck favorable (t412 restoration + borrow_match guard verified,
  hk86 intact).
- full01 (RUNID=ains1b-stepb-full01): historical 243209ae manifest
  (sha 25135c6a, 1466 cases) + final cd62b1ec src/binary: 1466/1466
  cases + 5/5 scripts green, global rc 1 explained solely by the
  unparseable `#` manifest line. See the desync postmortem record.
- t1474-t1477 (4 neg tests): manual both-target rejection verification
  only, no battery run yet.
- Focused batteries on the final binary: 54-case view, 13-case output
  guard, 36-case borrow (incl. t412): ALL GREEN Linux+Wine.
- Corrected manifest f75b8137 (1470 cases, parses clean) exists at
  676db8d4; never run as a whole; no cosmetic rerun planned.

Runner contract caveats (documented, improvement is a separate review):
- `pos` compares shell-normalized stdout ($( ) semantics: NUL dropped,
  trailing newlines stripped); it does NOT require exit code 0.
- `posx` checks the exit code; pos2/streams check exact bytes/success.
- A PASS line is therefore NOT a strict exit-0 claim for every case,
  and PASS outputs/exit codes are not retained per case.
- The full01 anchor set lacks the runner's own end hash; run anchors
  (src/bin/manifest/script at start, src/bin/manifest at end) are in
  the evidence tarball.
- No ABI-semantics-equal-to-LLVM claim: ABI was probed on the real
  emitted runtime for the view helper only (realabi01/02), not the
  whole surface.

Registered divergences (conservative, Harbour compiles/runs rc 0, this
compiler rejects at compile time): sub-view index mentioning an owned
root (t1474/t1475), borrowed-element index mentioning the owner
(t1476/t1477), two sub-views of one owner in a call (t1465), `? <array>`
prints empty in Harbour vs named error here, 4+-level literal nesting,
var-literal print width w10 vs w11, literal-space trim (NCUL vs
`N C U L` - pre-existing at bc364a5c, aDump impact unresolved until
step (d)).

OPEN: t528 (remains open, unaffected by this closure). Dyn float tag 5
reserved (no authorization). GT scope pending (blocks achoice family).
RC/shared-alias decision pending (out of (b) scope by construction).
Step (c) implements the immediate-output IIF union + hb_ntos(Dyn)
guard in isolation next; step (d) is the unadapted ains original, not
started.

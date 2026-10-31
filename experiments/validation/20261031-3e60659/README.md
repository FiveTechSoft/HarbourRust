# T1 validation evidence - honest state (2026-10-31)

Piece under validation: T1 - `Ty::Block` carries return kind (Int|Nil),
kind-aware eval. Compiler commit 3e60659, branch experiment/llvm-scalar-aot.

## State

- Battery (tests/run_battery.sh, Linux+Wine): ALL GREEN, 1389 PASS / 0 FAIL.
  Log: battery-3e60659-allgreen.log. Regression history:
  battery-21b135c-superseded.log (v1 snapshot 21b135c, 1387/1, superseded by
  v2 snapshot 5148433; v1 gates do NOT accredit the fixed tree).
- LLVM scalar gate (experiments/llvm-scalar/run.sh): INCOMPLETE. No green is
  claimed. See "Gate history" below.
- Original tests/t1.prg (external oracle, Harbour @694428e1, hbmk2 -gtstd):
  byte-exact on Linux AND Wine, 16000 bytes each
  (t1_original_oracle.out, t1_wine.out). Source NOT committed (license
  unresolved; MIT repo). Pins: md5 2a4b9aac74885cd38a2b95e1f66237fe,
  sha256 250205eaa1f29140bd069a4e988955fca45f8b4a20f5027085fd8716b41757ad.
- Verifier evidence (independent): verifier-evidence/ - snapshot results,
  negatives, source preservation, nil-arithmetic, t1v2 build log, published
  identity audit, revert identity audit (revert-identity-69e3b891.json:
  remote 96446df tree == 3e60659 tree e320c82, empty diff, harness blob
  strict again, src intact).

## Gate history (nothing hidden)

1. Attempt 1 (14:01, strict harness, compiler 3e60659): 167 PASS lines, then
   ABORTED at t49_nested_loop.hb windows/current: process produced correct
   stdout and exit code 0, but wineserver wrote
   "Unhandled page fault ... starting debugger..." to stderr and the gate
   contract requires empty stderr. Log:
   llvm-gate-attempt1-aborted-t49-wineflake.log (the original failure,
   preserved). Cause remains HYPOTHETICAL (Wine shutdown crash in a wineserver
   thread after correct execution). Diagnostic only: the same exe ran 10/10
   clean afterwards and the case passes the battery (which discards Wine
   stderr). These reruns are diagnosis, not acceptance.
2. 5835276 added an auto-retry to the gate harness. An independent audit
   (mocked subprocess exec of the exact committed loop; audit-evidence-5835276/)
   reproduced 3 false greens: wrong stdout discarded unchecked, retry firing
   on Linux, and arbitrary program stderr excused by substring match. The
   retry's commit message claim that output mismatches still fail was false
   for discarded attempts.
3. 96446df reverts 5835276. Net tree diff 3e60659..96446df is EMPTY
   (verifier-confirmed on the remote). src/ was never touched by the harness
   commit or its revert.
4. Attempt 2 (14:46, under 5835276's retry harness - the one the audit later
   proved unsafe) was killed after ~2 minutes and accredits NOTHING. Log
   preserved: llvm-gate-attempt2-killed-for-guard-fix.log.

## What this bundle does NOT establish

- A full LLVM gate pass for this tree. Per main's decision there is no third
  full gate for now; any future validation first needs a bounded Wine
  diagnostic and an evidence contract (no error silencing, no infra/permission
  changes).

## Design notes carried by the piece

- t870 conversion: block return kind from last body expr (output call or
  sig.nil_ret_only -> Nil, else Int); flows via decl/assign/params/return.
- Same-kind reassignment OK; kind-mixing at same arity is a named rejection;
  block params pin Int kind; block-return and iif-of-blocks stay named
  rejections; LLVM backend keeps its BlockLit named rejection (subset charter:
  explicit named rejections, no parity claim).
- t1390 registers an HR-internal runtime error pin (clean type error, rc=1,
  callstack on stdout). It does NOT accredit Harbour's interactive ErrorBlock
  dialog model; the mechanism difference is registered, not hidden.

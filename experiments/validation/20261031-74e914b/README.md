# Strings piece validation evidence - honest state (2026-10-31)

Piece: integer `Str(n[,w])`, `hb_ntos(n)`, `PadR(s,w)` builtins (achoice
original language support, non-GT part). Fixed tree 74e914b on branch
experiment/llvm-scalar-aot; history: cd9fea6 (piece) -> 74e914b (PadR()
zero-arg panic fix + guardrails t1403-t1405 + T1 README corrections).

## Scope (exact)

- Str: 1-2 integer arguments. Explicit width right-aligns/space-pads,
  asterisks when digits+sign exceed it; width<=0 falls back to default
  (max(10, digits+1) non-negative; negatives 10 if digits+sign<=10 else 20).
  hb_ntos: 1 integer argument, plain digits. PadR: 2 arguments (string,
  integer), pad/truncate/empty semantics. Decimals and any non-integer
  numeric argument remain named compile-time rejections; Dyn arguments
  rejected; owned-move semantics preserved. Claims are scoped to the
  oracle-probed shapes, not a general proof of Harbour field-width
  semantics. LLVM scalar subset boundary unchanged (string expressions
  were already outside it; identical named rejection before/after).

## Validation that exists

- Oracle provenance: all test expectations generated from Harbour
  @694428e1 runs (hbmk2 -gtstd), never from this implementation.
  Development probes s1-s6 with oracle outputs: probes/.
- Battery (tests/run_battery.sh, Linux+Wine) on 74e914b: ALL GREEN,
  1403 PASS / 0 FAIL. Log: battery-74e914b.log.
- Pre-merge probes: 7 pos tests byte-exact vs oracle on Linux AND Wine;
  named rejections verified for float/string args and arity.
- Post-fix bounded validation: repro shapes nominal on linux/windows/
  --experimental-llvm; compile-only panic sweep of the whole suite
  (1396 tests x 2 targets = 2792 compilations): zero panics
  (compile-only, NOT an execution battery).
- Independent verifier: cd9fea6 audit (verifier-evidence-cd9fea6/:
  12 positives Linux oracle-exact, 12 Windows build-only, negatives
  nominal except the PadR() panic) and 74e914b recheck
  (verifier-evidence-74e914b/: panic fixed nominal in all 4 contexts,
  12 Linux oracle-exact, docs corrections confirmed, remote/tag/bundle
  identity 74e914ba462e9d260e4a89a03f3ef06d751f0442 tree
  29d8b629d00a50f25ccfb7b6c3ea245058d7dee0).
- Focused Wine execution (verifier, completed 15:27:56): 12/12 cases
  (7+5), each run once, rc=0, stderr empty, stdout oracle-exact and
  matching Linux. Evidence: verifier-evidence-74e914b/wine-results-5c7e9f81.json.
  With this, the independent review of the BOUNDED piece (integer
  Str/hb_ntos, PadR(string,int), the PadR() panic fix) is CLOSED.
  This closure does NOT cover achoice itself, the LLVM backend, or a
  complete gate.

## Bug history (nothing hidden)

- cd9fea6: PadR() with zero arguments panicked the compiler (rustc exit
  101, slice index args[1..] on an empty slice in the walker pin arm,
  before any arity check), both targets and the LLVM path. Found by the
  independent verifier. Repro + pre/post-fix outputs:
  padr-panic-evidence/. Fixed in 74e914b (walker never indexes past
  args[0]; apply_moves iterates). Guardrails: tests t1403-t1405.

## LLVM gate (INCOMPLETE, scoped to cd9fea6, not attributed to 74e914b)

- One strict run (started 14:56, under the agreed evidence contract: no
  auto-retry, no error silencing): 342 PASS lines, then ABORTED at
  t1246_pp_smart_escape_marker.hb windows/current. Log:
  llvm-gate-cd9fea6-aborted-t1246-wineflake.log (explicit failure,
  preserved). Aborting run observations: rc=0, stdout exactly the
  manifest expectation, stderr one wine shutdown line ("Unhandled page
  fault ... starting debugger..."), a byte-identical fault signature to
  the T1 t49 incident (14:40, different executable).
- Diagnostic (observations only, never acceptance):
  diagnostic-t1246-10reruns.log - 10/10 reruns of the exact preserved
  exe clean (rc=0, expected stdout, zero stderr). No cause and no flake
  rate attributed. The T1 t49 incident has its own 10/10 diagnostic in
  the T1 bundle (experiments/validation/20261031-3e60659/).
- Per the agreed contract: no restart and no further suite without
  coordination; whether and how a complete strict gate can be obtained
  for this tree is an open coordination point with main/verifier.

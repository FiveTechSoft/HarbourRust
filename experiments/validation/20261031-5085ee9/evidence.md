# ains piece 1a - validation evidence (5085ee9)

Snapshot under review: commit 5085ee94, tag ains-1a-5085ee9, branch
experiment/llvm-scalar-aot. Incremental bundle (base 6e65a2e):
ains-1a-5085ee9-inc.bundle. The tag supersedes a first push (a124d58)
that accidentally included 6040 untracked gen/ build artifacts; that
commit was abandoned within minutes via force-push before any review
package was handed out. gen/abi.stderr.expected was and remains the
only tracked gen/ file; .gitignore now excludes /gen/.

## What the piece is

Mixed scalar literals {1,"x",NIL,.T.} type as Ty::DArrDyn: 16-byte
{tag,payload} cells (0 int, 1 NIL, 3 logical, 4 owned string copy)
under exclusive ownership; hbc_dfree frees cell payloads and the block
at scope exit. Cells readable in place: printing, ValType, integer
arithmetic. Everything else in mixed arrays is a named rejection.
Tag 5 remains reserved (float decision pending with the user).

## Proven facts (executed, oracle-compared)

- orc1.out / orc2.out: Harbour @694428e1 (Linux, hbmk2 -gtstd) output
  for the two positive programs. tests/t1422 and t1423 are those
  programs plus a trailing `? hb_memcheck()` line (internal harness,
  expected 0). The compiler output matched the oracle bytes and the
  memcheck line printed 0, including across two consecutive calls of
  the function owning the array (double-call run after the double-free
  fix below).
- Battery after the fix: 1424/0 ALL GREEN on the final full run
  (1419 prior + 5 new tests). This is a strict-suite green for THIS
  tree; it is not presented as proven absence of regression - see the
  t528 incident, which the battery run does not explain.

## Bug found and fixed during validation

The Dyn print path freed a tag-4 payload for any non-Var expression.
A DArrDyn cell read is a borrow (the cell owns the payload), so the
epilogue hbc_dfree then double-freed: second call of a function
printing a string cell segfaulted; memcheck read -1. Fix: the
free-after-print is scoped to owned temporaries (a DArrDyn Index read
is excluded). Evidence trail: dd1-dd5 probes (recorded in the agent
transcript), final t1422 passing with memcheck 0 over two calls.

## Repinned negatives (repins/)

t139_arr_neg_mixed and t697_strlit_mixed pinned the pre-piece-1a
boundary where ANY mixed literal was an error. Piece 1a makes mixed
scalar literals valid, so both were repointed, not deleted:

- t139.before.hb / t697.before.hb: sources as of 6e65a2e. Old
  expectations: t139 `array elements must be integers`, t697
  `array elements must be integers or logicals`.
- t139.after.hb: {1, "dos", {3}} - a nested array inside a mixed
  literal. New expectation: `array elements cannot mix integers and
  arrays` (the surviving named rejection).
- t697.after.hb: {"a", x} with x a variable - a non-literal element.
  Expectation unchanged (`array elements must be integers or
  logicals`): the old message now fires for the non-literal form.
- Reason for the boundary move: the 25Oct array commission (user
  originals: arrays dynamic and multidimensional) as delimited for
  implementation by main on 31Oct 16:16 (heterogeneous/nested arrays
  with exclusive ownership for ains; named rejections for unsupported
  forms; no silent copies).

New negatives: t1424 (x := a[i] rejected - the cell owns its payload;
storing it into a Dyn local would double-free), t1425 (a[i] := v
rejected - the overwrite path with old-payload free is the next
piece), t1426 (hb_isnumeric is an unknown-function rejection in this
piece; the builtin lands next).

## t528_hget incident (t528-incident/) - UNRESOLVED, not attributed

Timeline (all times 31Oct CET, compiler binary identical throughout -
sha256 in hashes.txt):

1. ~16:47 battery run 1: FAIL tests/t528_hget.hb (output mismatch;
   builds and exit codes had passed per the harness's fail path).
2. ~16:49 battery run 2: same FAIL.
3. Between runs 2 and 3 the only changes were t139/t697 test files
   and manifest entries - nothing touching t528, hashes, or codegen.
4. Post-run-2 preservation: the gen/ artifacts of run 2 were copied
   out (this directory). The preserved LINUX BINARY from the failed
   run, executed again at ~16:54, produced output byte-matching the
   manifest expectation. The t528 source also passed standalone on
   both targets at ~16:51 (rebuilt from the same compiler).
5. ~16:51 battery run 3 (after the t139/t697 repins): t528 PASSED;
   suite ALL GREEN.

Facts: two consecutive in-battery output mismatches; the preserved
binary from the failed run later produced correct output; the final
run passed. The harness did not retain the failing runs' actual
stdout bytes, so expected-vs-actual for the failures themselves
cannot be diffed - what exists is: manifest expectation
(`\n         1\n         2\n         1\nNIL\nNIL`), the preserved
run-2 binaries/asm/PE (sha256sums.txt), and the post-hoc passing
outputs. Cause is NOT attributed (environmental, harness, and product
causes all remain open). No further full retry was run; the preserved
binaries allow bounded reproduction attempts.

## Deferred within the piece (not blockers)

hb_isnumeric/hb_isarray builtin checker+emission arms (ains's guard
lines need them); then piece 1b (nested owned subarrays, tag 6) and
pieces 2/3 (AIns/ADel/AFill/AClone). Continuing in the isolated
working copy; the snapshot above is untouched by that work.

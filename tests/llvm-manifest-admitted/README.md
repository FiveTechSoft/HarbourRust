# Execute all admitted exact-output manifest inputs through LLVM

Own MIT coverage increment, no compiler/runtime changes. Scan the pos2/streams/
streams2 Linux manifest inputs and execute EVERY source LLVM admits. Require
exact rc0/stdout/stderr against the committed Linux expectation on native,
LLVMtraced and LLVMuntraced. Rejections are counted separately and must be
clean rc1,no emittedIR. Infrastructure failures assert,never become skips/PASS.
This uses existing manifest expectations,NOT fresh Harbour or new language
admission. --scan-only records admission without claiming runtime exactness.

Fresh run on compiler826d7245c5be17a455611bb55dd87366bd69b1b219c04b9f96d16e19be659c2c:
1185sources scanned,355admitted and executed x3=1065exact,830cleanrejections.
This expands answerable coverage beyond the fixed206source corpus,not a claim
that the other830language features work. No new upstreamoriginal admitted.
Prior immediate compiler gate was Rust113,Python64pass2skip,Linux1185,
negative618x2targets unchanged,census1041/60same,57original340clean2DELTA2;
those earlier gates are NOT rerun in this test-only increment. No fresh
Harbour/fullPEemission/Macruntime/performance/allhistorical-suite claim.

Commands,cwd,inputhash,rawemit/build/runout/err/rc retained. Run from repository
root so unchanged source include/metadata paths are preserved. Source copy is
retained for identity,not substituted as the compiled input. Companion .ch and
expected byte files remain in the same reviewed source tree.
No ownership/RC/ASort/numericdivision/workflow/push/publication/rebase changes.
JulioPonceMITspecifications only,no suppliedimplementation/cambio.diff copied.

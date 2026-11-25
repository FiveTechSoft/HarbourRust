# Current LLVM error and trace replay

Own MIT tests-only evidence,no compiler/runtime change. Existing23error
fixtures run native,tracedLLVM,and independent tracedLLVMrepeat:69triples
all rc1,stdout byte-exact to native,empty stderr. This is NOT freshHarbour,
not untracedLLVM,and not all possible errors. Includes bounds read/write,
checkedincrement,logic/sequence/loops,calls/recursion,void/NIL,borrowed output,
bitops/minmax/Empty/bool/scopedlocals and included-file origin.

Separate frozen trace-interning canary:6sources x Linux/Windows profiles=
12emission-only checks. Exact immutable text bytes/lengths,ordered update
sequence digest,unique-text counts,volatile pointer stores match committed
canary. Windows runtime NOT executed. Actual LLVM IR retained as the object
under test,not executables/objects/native assembly. Source/hash,build/run
commands,cwd,rc/stdout/stderr retained. No stdout substitution or normalization.

Compiler66e785f52a9c6a583eaed79bb184a715db5fbcf2d118f9abb45ba7e56943e623.
Broad Rust/manifest/originals/performance not rerun in this test-only commit.
No new admission,ABI/ownership/RC/numericdivision/workflow/push/publication/
rebase change. JulioPonceMITexamples specifications only,no implementation
or cambio.diff copied.

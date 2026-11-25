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

## Clean current-frontier25 refresh

Tests-only evidence on compiler4b7ddd4212ad976e97cb74b3367ef5b80877d1cafeef089dc985309ffdf856c8.
Original check.py run uninterrupted from beginning to end in a new output
directory,no resume,no cached command-result reuse.1185scanned,357admitted
x3routes=1071exactmanifest,828cleanrejections. Not freshHarbour:expectations
are repository manifest files. This supersedes the earlier resumed run only
for a clean-completion claim,not for history. No compiler change,new admission
or global/performance/PE/Mac repeat. Raw commands/cwd/source/hash/rc/stdout/
stderr retained. Existing ownership/RC/ASort/numericdivision debts unchanged.

## Fresh immutable string-tree frontier execution

Compiler 51e8ddf1eb012114ec5c1f0dab6af9b0d45cc996cbbda1c0c065ccc094760bfe.
Fresh uninterrupted full Linux exact-output manifest scan: 1185 sources,
359 LLVM admitted, 826 named LLVM rejections. All 359 admitted inputs ran
native, traced LLVM and untraced LLVM, 1077 byte-exact rc/stdout/stderr
triples against repository manifest expectations, not a fresh Harbour oracle.
No implementation change or universal compatibility claim. Four concurrent
shards partitioned the manifest by original line index modulo four; runner
and all command/rc/stdout/stderr evidence are packaged. No resumed records.
No push/publication/workflow/rebase. Performance measured separately.

## Fresh firstbyte/size-tree frontier execution

Compiler 737836bc4fe50e40d4105e5bd62aaf5d2982165d66352dc3a31069e6e1078ce7.
Fresh four-shard uninterrupted scan1185,359admitted,826rejected; all359
native/traced/untraced triples byte-exact against repository manifest,
1077triples total. No fresh Harbour/fulloracle claim or resumed records.

## Fresh Linux LLVM console-fix execution

Compiler2338925db21cbe386aa2aa10c0160ffa8f992023b4e79de18770660f3063bb7d.
Four fresh uninterrupted shards:1185scan,359admitted,826rejected; all359
native/traced/untraced triples exact against repository manifest,1077total.
No resumed records or fresh Harbour/fulloracle claim. No compiler change.

## Fresh immutable-print execution

Compiler8d6760e356385d8acda58d87326f5f781796448383161d13d4e2d916f57135ae.
Fresh four-shard scan1185,371admitted,814rejected; all371native/traced/
untraced triples exact against repository manifest,1113triples total.
No resumed records or freshHarbour/fulloracle claim. No compiler change.

## Fresh print-only selection execution

Compilerefbbdc50e71c4a4162f2170821c831b3ecf7a51d711369198f53d096e04597ff.
Fresh four-shard scan1185,371admitted,814rejected; all371native/traced/
untraced triples exact against repository manifest,1113triples total.
No resumed records or freshHarbour/fulloracle claim.No compiler change.

## Fresh immutable concat-initializer execution

Compiler9b50d99477f2ce40b86360f7b4cc926d889f3fd7be585bf321fe8af77f0edbbe.
Fresh four-shard scan1185,371admitted,814rejected; all371native/traced/
untraced triples exact against repository manifest,1113triples total.
No resumed records or freshHarbour/fulloracle claim.No compiler change.

## Fresh immutable string/NIL execution

Compiler61b28c969359680cfec4fcc48450aa3b0143c8f0b3b0e9fc0c06db640f07c33a.
Fresh four-shard scan1185,371admitted,814rejected; all371native/traced/
untraced triples exact against repository manifest,1113triples total.
No resumed records or freshHarbour/fulloracle claim.No compiler change.

## Fresh nested print-only selection execution

Compilerac70cc8d99fa478cb4e8537f555c8c89f7e7507047abab522dcd83b5b7943fad.
Fresh four-shard scan1185,371admitted,814rejected;all371native/traced/
untracedtriples exact against repository manifest,1113triples total.
No resumedrecords or freshHarbour/fulloracleclaim.No compiler change.

## Fresh length-only selection execution

Compiler98f1af4edb43601f1a585b2adcdf9e6129a8770c1c113488292c6114751a9aed.
Fresh four-shard scan1185,371admitted,814rejected;all371native/traced/
untracedtriples exact against repository manifest,1113triples total.
No resumedrecords or freshHarbour/fulloracleclaim.No compiler change.

## Fresh Empty-only selection execution

Compiler60c199133d23463b773c000f2c8303829fc78ab2d2f80fea152d4258e9dff93e.
Fresh four-shard scan1185,371admitted,814rejected;all371native/traced/
untracedtriples exact against repository manifest,1113triples total.
No resumedrecords or freshHarbour/fulloracleclaim.No compiler change.

## Fresh Asc-only selection execution

Compiler6c6df6c14b2aea47c3a673d6209dc22f64c32d1c12fa681fcafaf78a66146c99.
Fresh four-shard scan1185,371admitted,814rejected;all371native/traced/
untracedtriples exact against repository manifest,1113triples total.
No resumedrecords or freshHarbour/fulloracleclaim.No compiler change.

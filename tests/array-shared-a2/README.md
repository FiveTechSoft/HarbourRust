# A2 local shared arrays, own MIT implementation

Stacked on A1 252f19b6, not published. No workflow changes.

## Entry and scope

Ordinary native Linux only, without threads, macros, external functions or
classes. A program enters A2 when an empty local array gets a direct alias,
or is passed to a function that appends to that parameter. Once entered,
constant array literals in that program use shared tag-16 objects. Discovery
propagates direct local aliases, optional NIL/empty selections, direct
parameters, direct return variables and calls returning those variables.

This is a bounded shared-heap stage, not a global replacement of every old
array representation. In programs that do not enter A2, fixed array copying
and the other old contracts remain unchanged. The legacy manifest tests
for fixed-copy behavior therefore remain valid. The old negative
`t436_neg_darrs_arg_moved` now compiles on Linux intentionally: its empty
array reaches a mutator and remains usable by the caller. Windows retains
its former rejection. No other negative result changed against A1.

Admitted operations include heterogeneous scalar AAdd, local alias copies,
direct parameter sharing/forwarding, direct shared returns, scalar cell
reads/writes, nested shared cells, ASize, rebind without changing other
aliases, cycles and Break/CATCH with shared values. String and float cells
own their payload copies; Date and timestamp cells are payload-free.

Hashes, blocks, function references, by-reference storage, MEMVAR, FOR EACH,
Array()/HB_HKeys()/HB_HValues() and computed array literals are rejected in
an A2 program. Existing module-level restrictions remain in force. No claim
is made about unrestricted array constructors, all callback/escape paths,
objects, PE execution, Mac execution or B method results.

## Lifetime model

The existing stable object identity and registry are extended with a mark
word. Statement boundaries in A2 programs run a conservative collector:
exact tag-16/object pairs on the active language stack and module roots are
marked, pending exceptions are marked, graph closure follows tag-16 cells,
and unmarked registry objects release their scalar payloads, cells and
object allocation. Candidate stack pointers are matched to registry entries
before dereferencing. Cycles are handled by graph closure, not reference
counts. A caller's pushed arguments and intermediate pairs remain roots
when a callee reaches a statement boundary.

Conservative scanning may keep dead objects alive until stale frame words
leave the active stack. This is not prompt reclamation or a general
memory-safety proof, and no collection-latency or throughput claim is made.
The final process sweep still exists. The instrumented memory tests measure
both repeated-call steady state and strict final balance after persistent
cleanup and cache flushing. Recoverable scalar-cell stores register their
owned RHS in the existing auxiliary unwind stack before index evaluation;
normal completion pops it after installation. Failed bounds and index calls
therefore release owned strings/floats under CATCH.

## Provenance

`e12.prg`, its byte-exact Harbour 3.2 stdout, and `e13.prg` were supplied by
Julio and are retained as attributed test specifications. Julio's diff was
not applied or copied. The compiler, collector and other fixtures are our
own MIT implementation. There was no supplied independent Harbour stdout
for e13; its `pending 0` requirement comes from its supplied program and the
exercise's own assertions. Do not present it as a Harbour differential.
Other fixtures are our own asserted tests, not independently measured
Harbour oracles.

## Check

Run:

    python tests/array-shared-a2/check.py --compiler target/release/hbc --output /tmp/a2-check

The directory must not exist. Evidence includes every build/run stdout,
stderr and return code. The checker runs 9 programs in native, external-as
and no-VAS modes, checks 9 strict final DELTA guards, two limits and 15
unsupported-profile rejections. The nine programs cover Julio e12/e13,
cycles and returning aliases, shared exceptions, scalar failed stores,
nested failed stores, parameter/local rebinding, caller argument temporaries,
and string/float/Date/timestamp cell forwarding.

The wider Linux positive manifest has 1174 exact-output passes. A1 retains
18 exact runs, 6 final DELTA=0 guards, 2 limits and 6 profile rejections.
Rust tests: 99 passes. The PE compile/diagnostic-only gate has 1909 PASS,
22 pre-existing KNOWN-MISMATCH and 0 FAIL; this is not PE runtime evidence.
The historical two-target negative manifest comparison has 13 mismatches,
12 already present at A1 and the intentional Linux sharing change t436
above. No mismatch is silently treated as a new pass.

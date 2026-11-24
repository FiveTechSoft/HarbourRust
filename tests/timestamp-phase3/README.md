# Timestamp phase 3: shared local arrays

Own MIT implementation on dc1bea06c73c45a718fe89326ff833613bbd05e1.
Julio Ponce's MIT programs and Harbour outputs are specifications only.
No implementation or diff from Julio or Harbour was copied. No push,
publication or workflow changes are part of this delivery.

## Contract

Activates the existing A2 shared-array path when a class-free ordinary Linux
program contains hb_SToT/hb_DToT and an empty array constructor. It does not
add another array runtime or change timestamp representation. Tag17 remains
a non-owning scalar timestamp; tag16 remains a shared-array reference.

Timestamp arrays now admit mixed strings/scalars, aliases, function returns,
rebinding and bare LOCAL slots assigned an empty array inside a loop. A2
handles array-only cycles and local lifetime. Runtime consumers still check
the tag, so a shared-name classification never proves a value is a timestamp.

The change is deliberately two small integration hooks. All A2 restrictions
remain: no hashes, blocks, by-reference storage, MEMVAR, FOR EACH, unique or
computed array constructors, or mixed object/array graph. Classes do not
activate this bridge. B2's separate method/DATA behavior is unchanged.
No timestamp comparison, generic Empty(Dyn), hash/DATA/FOR EACH expansion,
Windows/Mac/LLVM/thread/macro/extern support is added here. e16 and t05 still
fail and are NOT claimed resolved. Predicates alone do not activate this
bridge, preserving the previous aggregate-predicate limit.

## Verification

    python tests/timestamp-phase3/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --output /tmp/ts3-check

Run from the repository root. The output directory must not exist. Gate:
51 rows, comprising 20 fresh Harbour exact executions from five own programs
in four Linux modes, four own runtime-error executions, six strict final
allocation balances, 18 profile rejections and three named A2 limits. The
own runtime test checks 202 catches, not equivalence to Harbour Error objects.

Original t06 is unmodified and matches fresh Harbour 3.2.1dev r2610242111 in
four modes, with strict final DELTA=0. Original e17 completes its internal
repeated result/exception assertions, prints pending 0 in four modes, and
has strict final DELTA=0. e17 is NOT a fresh Harbour differential because
hb_memcheck is not linked by the default oracle. Source hashes and raw
stdout/stderr/return-code logs are included in the review evidence.

A final guard succeeds only with exact stdout, rc=0 and empty stderr. Missing
DELTA alone is never treated as success. Allocation balance is measured
evidence, not a proof of general memory safety.

Regressions: timestamp1 complete; timestamp2 61; B2 115; B1 152; A1/A2 pass;
Linux manifest 1174 exact outputs; Rust 99; PE emission/diagnostics only
1909 PASS, 22 known mismatches, 0 FAIL. The 622 two-target negatives are
identical to the phase2 baseline, including 13 known mismatches. No native
PE/Mac runtime claim is made.

The review package includes incremental bundle/format-patch, LEEME,
manifest SHA, compiler SHA and reduced raw text evidence. No executable,
object or disposable assembly is included. The actual base contains the
unrelated docs/BATTERY.md update; this change does not touch that file.

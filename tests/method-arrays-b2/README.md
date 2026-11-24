# B2: method arrays and DATA roots

Own MIT implementation based on 15f686e5d262a99190ed3cdfbc368fd877c29490.
No workflow changes. No push or publication is part of this delivery.

## Contract

Ordinary native Linux x86-64 only. B2 activates when a method contains an
empty array constructor `{}` in the admitted profile. A2 shared arrays can
then leave methods, pass through ordinary functions and typed messages, and
be stored in DATA. Arrays keep identity across local aliases, rebinding,
DATA reads and returns. DATA initialization templates remain scalar-only.

Objects retain B1 reference counting and individual allocations. B2 adds an
intrusive list of live objects. The shared-array collector marks tag-16 DATA
cells of every live object as roots before scanning array edges. This is a
bounded object-to-array root bridge, not a general mixed tracing heap.
Objects cannot be stored inside arrays or DATA, so mixed object cycles are
not supported. Array-only cycles use the existing A2 collector.

Prior owned Dyn and typed-object call arguments have unwind guards while
later arguments evaluate. A failure releases these boundary references;
success removes the guards before handing ownership to the callee. Owned
string parameters are rejected because their deferred move requires a
separate protocol. DATA writes screen dynamic values before installation.
Rejected dynamic objects release the copied/transferred reference first.

B2 admits `Len()` of method/DATA Dyn results and integer Dyn FOR bounds,
including cleanup of owned invalid results before a caught type error.
`::n++` is parsed as a DATA read/add/write. Borrowed Dyn arithmetic/comparison
and DATA scalar operations retain existing runtime kind checks. General
owned Dyn arithmetic is still rejected. Scalar DATA text growth/comparison
has its own differential and strict final-balance test.

## Limits and divergences

This is not general Harbour dispatch. B1 descriptor-selected receivers keep
their explicit integer/logical/Date argument limit. This increment rejects
STATIC, SWITCH, FOR EACH, MEMVAR, inline sequences/assignments, hashes,
blocks, indirect calls, by-reference storage, unique/computed array
constructors and computed array literals. Object DATA and array elements
are unsupported. Temporary DATA write receivers are unsupported (some
surface forms are already rejected by the parser). Store the receiver in a
local first. Existing temporary DATA read limits remain.

Owned Dyn condition/logical operands and owned Dyn arithmetic/comparison
other than scalar DATA reads remain rejected. Implicit Dyn-to-integer call
arguments and other Dyn builtins remain rejected. Dyn plus a static float
is still an explicit compiler limit. Typed owned-string parameters and
combinations of defaulted Dyn object screens with typed object parameters
are rejected. Shared-name discovery overapproximates methods returning
DATA; a marked name is not proof of an array. Runtime tag guards still
validate consumers. This can reject otherwise valid Harbour programs.

Runtime error checks here validate catching and ownership, not Harbour
Error-object or error-description equivalence. Invalid temporary LEN uses
the catchable type-error route in B2. No native Windows, Mac, LLVM, macro,
extern, module-static-object or threaded runtime support is claimed.

## Reproduce

From the repository root, with a real hbmk2 installation path:

    python tests/method-arrays-b2/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --output /tmp/b2-check

The output directory must not exist. Native, external-as, no-VAS and
no-escape modes are compared byte-for-byte to fresh Harbour output for 13
own programs. Each has a separate strict final allocation-balance check.
The own runtime-error fixture repeats four invalid operations 101 times,
checks 404 catches and unchanged DATA length, runs in three compiler modes,
and has a separate strict final balance. Named rejection tests and profile
rejections are reported separately. A final guard succeeds only with exact
stdout, rc=0 and empty stderr. Missing DELTA alone never means success.

The reduced delivery includes raw stdout/stderr/return-code logs, JSON
results, compiler SHA, incremental bundle, format-patch and SHA manifest.
It excludes compiler/test binaries, objects and disposable assembly.

## External specifications and attribution

Julio Ponce's MIT programs e14/e15 and Harbour outputs are specifications
only. No implementation or diff from Julio was copied. Original programs
are hashed in delivery evidence, not republished as own fixtures. e14 was
compiled unmodified against fresh Harbour 3.2.1dev r2610242111 and matches
in all four Linux modes; its strict final allocation delta is zero.
Unmodified e15 completes its own repeated exception/result assertions,
prints pending 0 in four modes, and has strict final delta zero. e15 is NOT
a fresh Harbour differential: its hb_memcheck helper is not linked by the
default Harbour oracle. This distinction is preserved in the evidence.

Regression evidence: B1 152; previous method-valtype 125 exact executions
including original p11; Linux manifest 1174 exact outputs; Rust 99 tests;
PE emission/diagnostics only 1909 PASS, 22 known mismatches, 0 FAIL. The 622
two-target negative results are identical to the B1 baseline, including 13
known mismatches. A1, A2 and timestamp gates also pass. No PE/Mac runtime
claim is made. Historical exploratory failures are not counted as passes.

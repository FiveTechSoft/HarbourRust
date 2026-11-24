# B1: descriptor-selected method results

Own MIT implementation, stacked on 89c00e3fa76a18ee50ac0f914ed3333c8ddbb1bc.
No workflow changes. No publication or push is part of this increment.

## Contract

Ordinary native Linux only. B1 activates when an ordinary function parameter
receives a message whose name occurs in unrelated class hierarchies. The
receiver stays Dyn. Each actual descriptor selects the exact implementation,
including inherited and overridden methods. Each candidate is checked using
its typed leading-Self call. Explicit message arguments are plain integer,
logical or Date variables/literals, not effectful expressions.

The caller receives an owned tagged result: integer, logical, Date, string,
float, object or an existing Dyn pair. A method can return different admitted
kinds on different branches. Strings and floats clone when borrowed; object
slots and returned borrowed Self retain one reference. Fresh results transfer.
Locals can copy/rebind the result, ordinary functions can return it, output
can consume it, ValType can inspect it, and Break/CATCH can carry it.

B1 replaces process-lifetime object slabs only in activated programs with
individual allocations and frees scalar DATA templates at normal exit. This
makes final allocation balance sensitive to leaked object references. The
ordinary runtime outside B1 is unchanged. These changes are not a tracing
collector for object fields. Object/container DATA remains unsupported.

## Boundaries

This is not general dynamic Harbour dispatch. It does not infer a dynamic
receiver from arbitrary expressions or method parameters. Typed direct
messages retain their existing ABI. Dispatch checks descriptors, not only the
member's name or a guessed static class. All selectable implementations must
pass the explicit-argument and result checks.

Activated programs reject containers, codeblocks/function references,
by-reference storage, MEMVAR, STATIC, SWITCH, FOR EACH, inline assignment and
sequences. Dyn DATA writes are rejected. Dyn arithmetic/comparison and Dyn
builtin consumers other than ValType and output are rejected. Owned Dyn
logical/condition expressions are rejected; assign to a local first if the
result is known to be logical. Implicit Dyn-to-integer call extraction is
rejected. Later arguments to ordinary user functions must be plain variables
or literals. Typed object output temporaries and temporary DATA receivers must first be stored in a local.
These are named limits, not equivalent Harbour behavior. Thread, macro,
extern, module-static-object, LLVM, Windows and Mac combinations are not
claimed. Forwarding an untyped explicit message argument can still be
rejected by signature inference; the fixture records that limit.

B2 is NOT included: returned arrays stored in DATA, full e14/e15, and a shared
array/object graph need a separate root/ownership model. The original e14
also has the independent parser limit `::n++`.

## Tests and provenance

Julio Ponce's MIT programs and Harbour outputs are specifications only. No
implementation or diff from Julio was copied. The own fixtures in this
directory are attributed to this project's MIT implementation. Unmodified
external p11 and v11 were compiled separately and match their supplied
`L O` output, with strict final DELTA=0. Their hashes are in delivery evidence.

Run from the repository root, using an actual hbmk2 executable, not a symlink
whose installation-relative discovery may fail:

    python tests/method-results-b1/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --output /tmp/b1-check

The output directory must not exist. The checker captures raw stdout, stderr
and return codes. Four Linux modes: native, external-as, no-VAS, no-escape.
There are 17 own programs with fresh Harbour differential outputs, 68 exact
executions, 17 strict final DELTA=0 checks, 15 named limits and 51 profile
rejections. One invalid-receiver case is an own runtime/error check with a
strict final balance, NOT Harbour Error-object equivalence. The runtime
exposes an error-description string; Harbour's default dialog prevents the
same headless oracle. The timeout of that exploratory oracle is not a pass.

Previous method-valtype differentials: 125 exact executions. General Linux
manifest: 1174 exact outputs. Rust: 99. PE emission/diagnostics only: 1909 PASS,
22 known mismatches, 0 FAIL. The 622 two-target negative manifest results are
unchanged from A2, including its 13 pre-existing/intentional mismatches.
A1, A2 and timestamp gates were rerun. No Windows/Mac runtime claim is made.

The checker deletes direct test binaries after use. Raw assembly/objects
created by the final balance harness are disposable and excluded from the
review package. Final guard success requires exact stdout, rc=0 and empty
stderr, never merely absence of a DELTA line.

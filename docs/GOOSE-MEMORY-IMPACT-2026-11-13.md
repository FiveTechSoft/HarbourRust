# Goose memory model: impact on HarbourRust

13 November 2026. Design study, not an implementation or a performance result.

## Answer

HarbourRust does not need to be discarded. Adopting selected Goose ideas can be
incremental. Adopting its complete memory model would require a substantial
redesign of lifetime analysis, allocation placement and escaping values, not a
rewrite of Harbour syntax, the preprocessor or the native toolchain.

Replacing allocation/free calls with a bump allocator alone would not reproduce
Goose's safety guarantees. Without new lifetime proofs, it could leave dangling
references.

## What Goose actually requires

The current specification describes N data stacks, computed statically. Each
simultaneously live resizable value occupies the top of its own stack. Growth
advances a pointer without moving the data; scope exit restores a saved watermark.
The compiler proves placement and that references cannot outlive their owners.
This is more than one arena per function. Goose permits aliasing, subject to its
storage, shrink, lifetime and recursion rules. [1-3]

The current project documents whole-program compilation, no escaping closures
and no dynamic dispatch beyond ADT tags. Recursive functions cannot retain
resizable data-stack storage across a recursive-cycle call; a caller-owned pool
passed by reference is one alternative. These restrictions cannot silently be
imposed on existing Harbour programs. [1-2]

Pools accommodate some graphs and caches by reusing slots. A reference to a
released slot can remain type-valid while observing its next occupant. That
policy does not automatically preserve Harbour object identity. The design notes
also distinguish existing slice pools from proposed future independent dynamic
stacks. Proposed features must not be described as implemented. [3-5]

## What survives and what needs work

| Area | Impact |
| --- | --- |
| Harbour syntax, preprocessor, tests and Harbour oracle | Retain them. Storage policy does not require different source syntax. |
| Compiler written in Rust, native x86-64, assembler/linker and external hbmk2 | Retain the infrastructure. Address-space reservation and page commitment need target-specific implementations. Goose's current C backend does not require HarbourRust to add a C compilation stage. |
| Fixed-size integer, float and logical values | Candidates to remain in registers or on the native stack. |
| Non-escaping local strings and arrays | Candidates for the first arena-backed path, after proving lifetimes and growth. Allocation, return, overwrite and every scope-exit path need consistent handling. |
| The 16-byte Dyn `{tag, payload}` container | Its size and ABI could initially stay. Pointer ownership needs a checked region/lifetime contract; a 16-byte representation is not itself a safety proof. Full inline Goose representation is not a prerequisite. |
| `@`, shared array/hash aliases, `AClone`, cycles and escaping codeblocks | Require explicit semantic contracts. A local stack cannot own data that remains live after its owner. Deep cloning and sharing must be tested separately. |
| PUBLIC/PRIVATE/STATIC and the C Extend boundary | Escape boundaries requiring a design. Persistent-state validation is outside this study. The current C bridge clones strings and returns owned strings; an arena must not invalidate these at C-call exit. |

This assessment inspected `Ty`, Dyn, frame sizes, dynamic-value cleanup,
`cg_ext_call`, statement/function code generation and the bridge ownership
contract at HarbourRust `b36537521f6c54fbc0da72162eda16952cd5531b`. It did not
validate persistent storage, callbacks or a Goose prototype. [6]

## Recommended route: a measured hybrid

Keep the current storage path for shared or escaping values and preserve the
bridge ABI. Add data stacks only where the compiler can prove local ownership.
Before claiming full dynamic compatibility, settle identity, aliasing, cycles and
callback lifetime contracts. A hybrid must not be advertised as "no heap" or as
an implementation of the complete Goose model.

A first isolated prototype should cover:

- Two local arrays with overlapping lifetimes, then two sequential arrays that
  reuse a stack, plus temporary strings built in a loop.
- Early return, EXIT/LOOP, nested calls, returned data and a borrow that attempts
  to escape. Safe rejection or the existing storage path is acceptable where
  an arena proof fails; an invalid pointer is not.
- Exact stdout, stderr and exit-status comparison against Harbour for positive
  cases. Measure peak RSS, committed pages, virtual reservations, generated-code
  bytes and median runtime against current hbc and Rust on the same machine,
  with both small and large inputs.

Only after these checks should an integration increment be proposed. No compiler
or allocator change is part of this document.

## Performance limits

There is no evidence here that adopting Goose would make HarbourRust the fastest
or the most advanced implementation. Goose's published benchmarks are from its
own project, with particular workloads, data representations and toolchains.
Some rows do not beat Rust. They do not predict the result of a HarbourRust
hybrid. Community criticism of the benchmark comparisons is context, not a
replacement for reproducing measurements. [7-8]

## Sources and version limits

Sources read on 13 November 2026. The observed Goose repository tip was
[`4602c98660676b2cb94bc9b06fec8c65b37fce92`](https://github.com/aardappel/goose/commit/4602c98660676b2cb94bc9b06fec8c65b37fce92),
dated 13 November 2026. The Pages specification is a working v4 draft; its HTML
does not establish that it corresponds exactly to that repository commit.

1. [Goose specification](https://aardappel.github.io/goose/docs/goose_spec.html),
   sections 1.2-1.3, 7.8, 9 and 10.3-10.4: memory, recursion, lifetimes and stack
   assignment. Primary design contract, not proof every rule is implemented.
2. [Goose repository and README](https://github.com/aardappel/goose): documented
   limitations, whole-program model and C interface/backend.
3. [Memory tutorial](https://aardappel.github.io/goose/samples/02_memory.goose.html):
   local ownership, data stacks, pools and logically stale references. The sample
   was read, not executed for this study.
4. [Owning dynamic data design note](https://github.com/aardappel/goose/blob/master/docs/design/owning_dynamic_data.md):
   current slice-pool costs versus proposed future independent stacks.
5. [Scope-exit cleanup design note](https://aardappel.github.io/goose/docs/design/scope_exit_cleanup.html):
   defer/destructor/finalizer proposals. Do not treat recommendations as shipped
   features or confuse releasing memory with releasing external resources.
6. [HarbourRust source inspected](https://raw.githubusercontent.com/FiveTechSoft/HarbourRust/b36537521f6c54fbc0da72162eda16952cd5531b/src/hbc.rs)
   and the [current milestone-1 bridge contract](EXTEND-BRIDGE.md).
7. [Goose benchmark results](https://aardappel.github.io/goose/bench/results.html):
   author-run measurements, dated 16 October 2026 in the fetched content. Best of
   three whole-process timings after two warmups, with specific C++ and Rust
   comparisons. Not an independent HarbourRust measurement.
8. [Community benchmark discussion, in Russian](https://habr.com/ru/articles/1105666/):
   secondary methodological criticism, not used as a numerical or safety result.
   Publication date was not confirmed in the fetched text.

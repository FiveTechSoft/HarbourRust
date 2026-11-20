# Mixed numeric Min/Max, bounded ordinary Linux increment

Own MIT tests. Harbour is an external executable oracle, never a linked library.

`check.py` compares unmodified PRGs, rc/stdout/stderr, internal and external
assemblers. It records baseline build rejection separately from runtime output.
The optional external P03 is read without rewriting it. Large values use runtime
doubles, not rejected decimal literals outside the existing precision frontier.
Ties must retain the first operand's numeric kind and integer display provenance.

`safety.py` runs instrumented lifetime/unwind checks in three modes, then checks
five excluded profiles and five existing limits. `memory.prg` warms up before
measuring net allocations. These are not Harbour error-semantics comparisons.
`mutants.py` builds isolated counterfactual compilers, requiring successful Rust
builds before a program rejection or runtime output difference can count.

No Cmp/Bin codegen, trace machinery, workflow, manifest or expected output change.
This is not general numeric promotion. New admission excludes PE, Mach-O, LLVM
and whole programs containing hb_thread*/hb_mutex* calls.

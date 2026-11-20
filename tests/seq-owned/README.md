# Owned strings in comma lists, bounded ordinary-Linux increment

Own MIT implementation and tests. No contributed diff was opened or copied.
The external p04 program is an unchanged oracle input, not product source.
Harbour is used only as an external executable for output comparison.

On ordinary Linux x86-64 without threads, a comma list may contain owned
strings. Evaluation is left to right, and only the final value is returned.
A completed temporary prefix is freed before the next element starts. A
variable prefix is borrowed. A final owned-string variable is cloned, so
Len/Empty/output/callee consumption of the resulting temporary cannot free
that variable's buffer. Nested calls still consume their own arguments under
the existing rules. The float-result emitter also frees string prefixes.
A pending string list in output is included in the existing local unwind
release categories. Trace emission and the trace finalizer are unchanged.

A non-empty literal local receiving a concatenation in the final list
position starts in owned-capable storage, through the existing shared
accumulator predicate used by checker/layout/codegen. Prefix concatenations
do not select the destination's kind. The arithmetic/concatenation emitter
and checker are not changed.

Limits remain explicit: generic owned Dyn temporaries, arrays, blocks,
inline string assignment, unsupported ValType expression shapes, and a
non-empty literal slot replaced by a final Upper/Lower call without prior
owned storage. This is not general type widening. PE, Darwin, ARM64, LLVM
and threaded profiles reject the new owned-string list forms.

Run check.py for byte-identical rc/stdout/stderr against external Harbour,
internal and external assemblers, with no normalization. The optional
--contributed-p04 reads that original from its separate input path. Baseline
compile rejection is recorded separately from runtime comparisons.

Run safety.py for two instrumentation-only checks (1000 iterations each,
2000 catches and zero outstanding allocation delta after warmup) and named
ownership/shape/profile rejections. Instrumentation is not compared with
Harbour. memory.prg covers string and float results, nested borrowed locals,
discarded statement results, prefix failure and pending output failure.

Run mutants.py --only with comma-separated names: no-prefix-release,
no-final-clone, no-float-discard-release, no-print-unwind-release,
no-list-promotion. Each builds isolated own Rust source and one relevant
workload. The first four yield runtime differences; the last yields a
program build rejection. A mutant compiler build failure is never a catch.

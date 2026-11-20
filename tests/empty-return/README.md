# Empty-array return boundary

Own MIT implementation and probes. No external diff or implementation was read,
translated or copied. Harbour runs only as a separate executable oracle against
unchanged PRG input. The contributed P09 is optional test input, not product code.

Ordinary Linux without threads preserves the unpinned empty-array return kind.
The caller can store it, copy it, or pin its element kind with the first AAdd.
Len on an unpinned temporary evaluates it once and releases its header through
the selected flat allocator family. Len on a variable remains borrowing.

This does not generalize array temporaries: nonempty temporary Len, discarded
array returns, unpinned generic parameters and mixed return types keep their
named rejection boundaries. Other targets and threads keep the previous return
rejection. No arithmetic/comparison, trace, renderer or terminal implementation
is changed.

check.py compares rc/stdout/stderr exactly with external Harbour in four modes:
internal/external assembler and VAS enabled/disabled. safety.py separates
instrumented lifetime checks from compile-only negative/profile checks. Its
owned-string exception workload excludes VAS; flat-only controls cover VAS.
mutants.py distinguishes runtime differences from program build rejection.
Pre-fix probes and full regression/census evidence accompany the review package.

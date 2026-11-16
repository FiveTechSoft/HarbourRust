# P1b: compact deferred macro errors

BASE92f5c7afbb08736c18035afc606d74b335ee82aa, including published DBF D1. This increment changes only macro value/error representation and its tests/docs/generated blob. It does not touch hbc.rs or DBF files and adds no builtin names or operator changes.

## Representation and lifetime

The old val embedded a512-byte diagnostic array in every value, including successful literals, lookups and operator results. P1b replaces that array with a static diagnostic prefix and an optional source-name span. val is96bytes, node144bytes and hrmacro_context224bytes (still below the existing256-byte root slot).

A top-level hrmacro_eval owns one512-byte diagnostic buffer on its stack and temporarily points the context's error_sink at it. On an error, eval_text renders before destroying the parser or its source/owned nested string. A propagated nested error already points into this sink; it is not formatted twice or changed by outer error propagation. Rendering preserves the previous bounded prefix/name behavior: ASCII uppercase name, at most510 content bytes and the final LF. No heap allocation is needed to report allocation failure. All error construction remains deferred; parse/fold/runtime order is unchanged.

The active sink pointer is cleared before successful return or fatal cleanup/callback. The top-level stack buffer remains valid during the fatal callback. raise_status and the STR argument adapter use their own local diagnostic buffers before destroying context storage. Compiler-owned successful values never point into the diagnostic sink. This does not add reentrant callbacks, recoverable errors, user-code calls, thread propagation or a retained/global error buffer.

## Final artifact and validation

Compiler SHA2565b07beec563a572e021489876f7ca24321ea36abbe079127b7997990960559a4, built on D1 BASE; independently built BASE compiler1dfdb8722aeb7c043f437aaf1b758bdf292fa9e3da82f419f4147d5d4fb6f312. Earlier f1533a8d evidence on pre-D1 BASE is not counted as final evidence.

- Host ASAN+UBSAN/leak check and PE host:10 PASS lines, exit0 and empty stderr. Includes inherited allocation-fault cleanup,164 N1 parsing checks, P1 reuse/mutation/nested tests, plus700-character missing-name truncation, nested-owned-source errors, builtin frames, repeated nested macros and no error_sink escape after clean/error paths.
-24 error/lifetime/truncation cases on each target compare separate stdout/stderr/exit exactly against D1 BASE, including long missing/unknown names, nested sources, error ordering and folded-away errors. The runner originally used Python repr for one mixed-quote expression and failed at case15; the harness was corrected to bracket string literals and all24 were rerun. It was not a production failure or an initial24/24 pass.
-16 terminal error/ordering cases per target match pinned official Harbour raw output, including builtin frames. M2 mixed/values positives4, capacity8 per target and real production-helper ABI both stack parities pass with actual internal-writer outputs where applicable.
- N1 numeric270-expression matrix on each target is byte-identical to D1 BASE;114 inherited oracle mismatches remain unchanged. No new large-number parity claim.
- Full1743 manifest rows each ELF/PE: zero raw BASE regressions;66/75 inherited fixture mismatches and12 inherited compile-blocked PE positives remain. Full battery executes captured assembly via external GAS/ld; the other PRG gates use autonomous internal writers. Five macro emission changes each target have full captures/diffs. New DBF features are not claimed newly validated by this macro regression run.
- Blob regeneration and all recipe source dependency hashes match; no symbolic address pointer table or symbolic movabs added. Clean BASE+patch build identity is a separate package check. PE is Wine11, not physical native Windows certification. No Mach-O/ARM64 run. Second-executor final-hash gate remains separate.

## Performance: close, not a global win

Final D1-rebased hash, Linux50000-iteration macro loops, six process samples and median lastfive, process startup included. Outputs match Harbour and end mem0. No direct-helper timing substituted for complete parse/lookup/dispatch/cleanup.

| Expression | D1/P1 BASE ns/eval | P1b ns/eval | Harbour ns/eval in P1b batch | P1b/Harbour |
| --- | ---: | ---: | ---: | ---: |
| Upper(s) |1222.17|578.64|547.04|1.058x slower|
| Lower(s) |1194.72|560.04|552.45|1.014x slower|
| n+1 |1224.98|350.71|371.59|0.944x, faster in this batch|

Separate BASE batches had Harbour781.34/519.21/374.55ns. Timing variation is visible in raw samples. P1b improves its BASE but does not establish that the whole macro path is faster than Harbour: short string cases are still slightly slower/near parity, and results are workload/hardware-specific. Earlier pre-D1 samples showed larger variation and are not the final measurements above. No general speed victory or complete compatibility claim follows.

## Reproduction

See tests/macro/p1b/REPRODUCE.md. Source https://github.com/FiveTechSoft/HarbourRust.git; external behavior oracle https://codeload.github.com/harbour/core/tar.gz/694428e1c12f726675b19324d62167fa77d68185. No oracle code is copied. This review package does not publish itself.

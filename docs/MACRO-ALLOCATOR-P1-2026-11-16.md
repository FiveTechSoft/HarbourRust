# P1: bounded context-local raw allocation reuse

BASE 18c781da22c3eb701dff7d7ce873e5cf65011eb2. Allocator-only increment. Deferred-error representation stays unchanged; compact errors belong to a separate later P1b. No M2B builtin additions are included.

## Implementation and lifetime

hrmacro_context owns four raw free-list bins (64/256/1024/4096-byte payload capacities). Backing allocations use the supplied original callbacks. Each block records owner, exact requested size, capacity and active/cached state. Release validates owner, active state and exact size. Double release, wrong size and cross-context release fail closed with a named internal P1 integrity error. Cached total is bounded to 256KiB INCLUDING backing headers. Exceeding the retention cap frees backing, not a new program capacity rejection; requests above4096 bypass bins. Header arithmetic is checked for overflow. Requested bytes are zeroed on every allocation, including reuse. newnode's second zeroing is removed under that allocator contract.

No parsed expression, source pointer, result or binding fingerprint is cached. Parse/fold/evaluate still run in full every time, in their existing order. Raw AST nodes, argv scratch and temporary bridge storage copies reuse backing; compiler-owned strings/floats stay on their original allocation/export/destruction path. No raw pool pointer escapes as a compiler result. Nested evaluations release only their own blocks, never reset an outer AST. Persistent context bindings share the allocator but remain active until their own release.

hrmacro_destroy first destroys bridge frames/bindings, then releases every backing block and clears bins/counters. It is idempotent. Fatal flow still destroys the context before invoking its callback, including the cache. Context size is216bytes, within the existing256-byte root slot; compile-time size assertion remains. No global raw cache or thread propagation is introduced; thread+macro restrictions are unchanged.

This callback-based raw allocator is not a general memory-safe free API for arbitrary pointers. Validation assumes a pointer returned by this allocator, with a readable header. Original production backing OOM can terminate before C sees NULL; host return-NULL fault seams do not prove general recoverable native OOM. Retained cache bytes during a live context are not live AST/binding resources and are reported separately.

## Validation

Final compiler SHA256854fad098e62544b19115cbb2e5a8ed75dba33a47a5d5ccb94acce27bff47d28. Generated recipe/source dependency hashes and regeneration identity are part of the review package. Clean BASE+patch build identity is checked separately.

- Pool unit: all four class boundaries, zero-length, oversize direct blocks, zeroing after dirty reuse, independent contexts,512-block saturation/eviction within cap, allocation failure/retry, SIZE_MAX overflow, exact backing sizes and destroy twice. Linux ASAN+UBSAN/leak check and PE host pass. Three Linux subprocess controls fail closed for double/wrong-size/cross-owner release. Initial non-LTO PE unit link failure is retained, superseded by successful -O2 -flto build; not counted as an initial pass.
- Evaluator host: previous allocation-failure cleanup matrices and164 N1 parser checks plus1000 mutable-text/nested-string runs,1000 steady-state calls with no new backing allocation, outer-source lifetime, fatal flush, destroy twice. ASAN+UBSAN/leak check and final PE host exit0 with empty stderr. Fatal callback observes original raw/compiler pools and scratch/frames/bindings already zero; no claim of unrelated generated LOCAL unwinding.
- Full1743-row manifest on ELF and PE: zero raw BASE regressions. External GAS/ld executes captured assembly; complete raw stdout/stderr/exit and emission captures retained.66/75 inherited raw fixture mismatches and12 compile-blocked PE positives remain. The secondary newline-tolerant zero is not a blanket raw-green claim. Five macro emission changes per target.
- N1 matrix270 each target: every candidate line identical to N1 BASE;114 inherited oracle mismatches unchanged. Autonomous internal writers also pass M2 mixed/values4 raw oracle comparisons with final mem0, fatal16 per target, capacity8 per target, actual production dispatcher ABI both parities/GPRs/argv/balance0.
- PE tests use Wine11, not physical native Windows certification. No Mach-O/ARM64 execution was tested. Independent second-executor final-hash PE confirmation remains a separate publication gate.

## Performance, not a speed victory

Final hash, Linux short-input macro loops,50000 evaluations, six whole-process samples, median lastfive. Includes process startup and actual parsing/MEMVAR/copy/cleanup; outputs match oracle and end mem0. No helper-only timing is substituted. Source and raw samples are retained.

| Expression | N1 BASE ns/eval | P1 ns/eval | Harbour ns/eval in P1 batch | P1/Harbour |
| --- | ---: | ---: | ---: | ---: |
| Upper(s) | 26032.66 | 1133.24 | 516.03 | 2.20x slower |
| Lower(s) | 27158.69 | 1384.80 | 520.68 | 2.66x slower |
| n+1 | 13119.12 | 1075.71 | 389.00 | 2.77x slower |

Separate baseline batches had Harbour509.86/518.91/389.08ns. These are sequential local measurements, not hardware-independent guarantees. P1 improves this baseline roughly12-23x but remains slower than Harbour. The speed requirement is NOT met. P1b error-representation work is explicitly next, before M2B publication. Syscall-count diagnostic on the earlier10k Upper fixture:50,009mmap+50,009munmap in baseline versus14+14 in P1; strace timings are not benchmark timings. Reuse reduction alone is not declared success on the final speed goal.

## Reproduction and sources

See tests/macro/p1/REPRODUCE.md. Source https://github.com/FiveTechSoft/HarbourRust.git. Official behavior oracle https://codeload.github.com/harbour/core/tar.gz/694428e1c12f726675b19324d62167fa77d68185. No oracle implementation is copied. No publication is performed by this review package.

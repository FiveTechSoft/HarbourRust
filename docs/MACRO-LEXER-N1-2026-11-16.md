# N1: preserve exact representable macro integer literals

BASE: 00e1d81ccdef2c7eed5f462a5da2f9d9fe84122b. This increment is separate from the next M2 builtin catalog unit. It adds no builtin names and changes no dispatch rules.

## Change

The macro number lexer accumulated a digit only when `iv < (INT64_MAX - 9) / 10`. That guard is safe against overflow but unnecessarily converts representable final integers 9223372036854775790 through 9223372036854775807 to double, losing exact integer provenance and low bits. The new guard is `iv <= (INT64_MAX - (c - '0')) / 10`. It uses the actual digit and permits exact INT64_MAX. The following multiply/add stays within signed int64. Actual overflow still changes to the existing double path.

This is a one-line shared lexer correction, not an M2B slice workaround. It also affects negative literals through the existing unary folding path and decimal accumulation through the same lexer. No other parser/operator/formatter code is changed.

## Evidence and limits

Final compiler SHA256: cc844ba32064085b7bf25c79343fa65f437d3d549e4442096bb545b91e02f6d1. Developer-generated blob and recipe are regenerated with the recorded MinGW GCC10 flags/dependencies. A clean BASE archive plus patch rebuilds the same compiler with rustc1.100.0, edition2021, opt-level1, debuginfo0, strip=symbols.

- Host assertions: 81 representable integers ending at INT64_MAX, 81 negatives, exact literal tags and payloads. True overflow at positive and negative 2^63 keeps the expected double bits and metadata. These 164 checks isolate parsing from large-number formatting. ASAN+UBSAN/leak checking exits0 with empty stderr. PE host exits0 with empty stderr. Existing M2 allocation-fault/cleanup host checks remain in that executable.
- Numeric matrix: 270 expressions on ELF and PE, each captured against both BASE and official Harbour 694428e1c12f726675b19324d62167fa77d68185. The matrix spans both signs, the old guard, INT64_MAX, overflow, decimal suffixes and arithmetic. Each target has 65 raw-exact improvements and zero regressions. 114 inherited oracle mismatches remain byte-identical to BASE. Every changed line now matches the oracle. This is not 270/270 parity.
- In particular, existing Str(Dyn) formatting for some large double values prints a ten-character asterisk field while Harbour uses a wider numeric field. Other large-number/operator differences in the matrix remain inherited. N1 does not claim to fix the general double printer, arbitrary precision, all overflow semantics or all large-number arithmetic.
- Full 1743-row manifest per target: zero raw BASE regressions, separate stdout/stderr/exit and complete emission captures. The full battery uses external GAS/ld, not autonomous output. The inherited 66 ELF/75 PE raw fixture mismatches and 12 compile-blocked PE positives remain; secondary newline-tolerant zero is not the primary verdict. Five macro-related emission changes each target are recorded.
- Autonomous internal-writer reruns: M2 mixed/values four raw oracle matches with final memcheck0; sixteen fatal/ordering comparisons each target, raw-exact. Matrix runs also use internal writers.
- PE is local Wine11 evidence, not physical native Windows certification. No Mach-O/ARM64 execution was tested here. Independent second-executor final-hash PE check is a separate publication gate owned outside this package.

## Reproduction

Use tests/macro/n1/REPRODUCE.md. Raw matrix results live in evidence/n1-matrix/{linux,windows}/results.json and the corresponding separate BASE/candidate/oracle streams. A failing inherited row is kept visible rather than normalized, removed or relabeled as passing.

Source/oracle: https://github.com/FiveTechSoft/HarbourRust.git and https://codeload.github.com/harbour/core/tar.gz/694428e1c12f726675b19324d62167fa77d68185. The official implementation is only a behavioral oracle, not copied into this increment.

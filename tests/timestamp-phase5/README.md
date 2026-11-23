# Timestamp phase 5: scalar Empty(Dyn)

Own MIT implementation on 6b8e5660a03656e68751fff98545adb05cc11a81.
Julio Ponce's MIT e16 and Harbour outputs are specifications only. No
implementation or diff from Julio or Harbour was copied. No workflow
changes, push or publication are part of this delivery.

## Scope

In ordinary Linux programs using timestamp builtins, Empty accepts a Dyn
scalar and checks its runtime kind: NIL; integer; logical; heap/immediate
float; Date; timestamp; borrowed/owned text. Empty float means numeric zero,
including negative zero. Empty Date/timestamp means zero payload. Empty text
means length zero or only space, tab, LF and CR. Other scalar kinds are not
silently treated as empty.

Results borrowed from locals, array cells and function parameters are not
released. Owned temporary cells are released after inspection, including
on the unsupported-kind error route. Arrays, hashes, objects and handles
remain outside the new Dyn consumer and raise the existing catchable type
error when they reach it. No container Empty behavior is claimed. Static
Empty behavior and non-timestamp-program limits remain unchanged.

This is not completion of e16. Its first Empty(Dyn) rejection is removed;
the next compiler rejection is Date passed through Compara's Dyn parameter.
Hash/DATA/FOR EACH integration, mixed Date/timestamp comparison and other
e16 blockers remain. No PE/Mac/LLVM/thread/macro runtime support is added.

## Verification

    python tests/timestamp-phase5/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --output /tmp/ts5-check

Run from repository root; output directory must not exist. Gate49: five own
programs with fresh Harbour differential output in four modes (20 exact
executions), four own runtime-error executions (202 catches), six strict
final balances, 18 profile rejections and one retained non-timestamp limit.
The differential byte fixture checks each byte0..32, not an assumed locale
whitespace rule. Other fixtures check borrowed Date/float/timestamp cells,
owned text/timestamp return values and exception propagation. Runtime errors
check ownership/catching, not Harbour Error-object equivalence.

Final balance requires exact stdout, rc0 and empty stderr. Missing DELTA
alone never means success. No whole-original e16 pass is claimed.

Regressions: timestamp1 42 exact +2streams/14balances; timestamp2 61;
timestamp3 51; timestamp4 50; B2 115; B1 152; A1/A2 pass; Linux1174 exact;
Rust99; PE emission/diagnostics1909 PASS,22 known,0 FAIL. Negatives622 are
identical to phase4 including13 known mismatches. No native PE/Mac claim.

Regenerate the own C helper with tests/generate_timestamp_asm.py. The recipe
pins hashes/compiler/flags and the existing five-call external whitelist.
The tracked generated assembly is compiler source, not disposable test
assembly. Reduced delivery includes incremental bundle/patch, LEEME,
manifest SHA, compiler SHA and raw text evidence, no executables/objects.

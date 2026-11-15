# B2: contextual MEMVAR and staged macro evaluation

BASE: 89b6389a6ab6e9d55e9e0d7b22db23db374ad478. Not published.
Final compiler SHA256: 94c047438bd7b818d2ebcf67adea29267f869674e270feed3d2a2dd918567acf.
Final generated assembly SHA256: 79ad5963ce97bd15dd733d21a12613f368cb7814f5ff46c750e9c994c629a9fd.

## Implementation

The flat M0 table is removed. `hrmacro_context` contains the B1 storage and
ownership bridge, a fatal callback, scratch count and lookup count. Root owns
256 stack bytes; real user trace frames carry context and frame mark. Child
frames inherit PRIVATE and PUBLIC, shadow PRIVATE and restore it on return.
PUBLIC survives child exits until root destruction. Defaults are declared,
not guessed: HARBOUR/CLIPPER absent before PUBLIC, .T. afterward, other PUBLIC
.F. Each frontend declaration precedes its separate initializer/put.

MemvarDecl/MemvarSet are real AST forms; resolver entries do not own a fake
LOCAL stack value. Direct declared reads/assignments use bridge get/put.
Runtime macros fully parse before lookup, fold only literal provenance, then
evaluate. Runtime tag9 is never treated as source-literal provenance. Folded
constant AND/OR branches do no lookup. V_ERR survives to cleanup before fatal;
first surviving runtime error wins. Temporary compiler strings and raw AST
nodes have separate ownership. Binding floats preserve both bits and metadata.

Internal SysV adapters separate raw allocation headers from compiler strings.
Raw free validates exact size and production registry identity. Compiler export
creates actual production string/float allocations. A generic builtin terminal
frame adapter supplies observable builtin name/line0 before user stack frames.
Dyn Str uses real integer/float formatters, never a stand-in formatter.

## Final evidence, not normalized

- Full original manifest: 1741 cases each ELF/PE, zero raw BASE regressions.
  ELF all positives executed; PE12 positives remain compile-blocked on both
  products. `battery-summary.json` lists them. There are 76 ELF/85 PE raw
  fixture mismatches already present in BASE; canonical-LF failures0 is only a
  secondary column, not a raw-manifest PASS. Four complete emission changes
  each target have full gzipped diffs; every successful emission is included.
- Four new PRGs x two targets match official Harbour694428e1 raw stdout,
  stderr and exit. They cover numeric/runtime provenance, mixed expressions,
  metadata, Str(binding_float), normal frame inheritance/shadow/restore,
  PUBLIC visibility/defaults, case/prefix/truncation, strings/logical/NIL,
  nested macros, overflow and final compiler memcheck0. Only test-only
  hb_memcheck() is replaced by0 in oracle sources; scope is explicit in script.
- Fatal matrix16 cases plus static-rejection4 checks: raw PASS20/20.
  Official test-only ErrorBlock reporter measures actual subsystem/subcode,
  operation and ProcName/ProcLine including STR(0), MAIN and child chain.
  It only selects terminal-headless reporting, does not test product recovery.
  Initial ErrorSys replacement approach hung in PE; original attempts and
  scripts remain visible. Initial missing STR(0) was fixed, not normalized.
- Current host ELF/PE and ASAN+UBSAN with leak detection: exact-pointer pools,
  zero raw/compiler/AST/frames/bindings observed INSIDE fatal callback before
  longjmp; syntax-before-lookup; no elided lookup; first-error ordering;
  48 raw and48 compiler allocation-failure points, all reclaimed.
- B1 native callback gate rerun from final compiler: native ABI sentinels,
  Win64 nonvolatile GPR/XMM/shadow writes/alignment, real production formatter,
  constructor parity gates and storage ownership pass. New B2 wrapper gate
  executes raw allocate/free and float/string export at both caller parities,
  checks RBX/R12-R15, stack restoration, exact37-byte raw header, real16-byte
  float slot bits/metadata and final compiler balance0 on ELF/PE. B2 callbacks
  are internal SysV; native Win64 crossing remains isolated in B1 test gate.
- `movswl` opcode0F BF F8 is asserted and the resulting ELF executes 0xffff
  sign extension plus1 -> exit0. Raw code/hashes/rc are captured.
- Generator reruns to identical assembly bytes. Recipe includes all source
  dependency hashes and compiler flags. -fcf-protection=none avoids unsupported
  ELF CET note in autonomous PE. Both autonomous outputs run in new PRG/fatal
  gates, in addition to full external-GAS battery.

## Terminal gate and frozen QOut handoff

ELF original three terminal fixtures: raw PASS. PE whole fixtures:
FAILED/INHERITED-DEPENDENCY-QOut, never PASS-with-caveat. BASE and final B2
captured on identical source have identical stdout/stderr/exit. At expected
stdout offset0 the missing byte is0d; expected0d0a6265666f7265, actual
0a6265666f7265. Fatal stderr separately matches CRLF, Called-from and exit1
byte-exactly. `evidence/QOut-required-flips.json` lists the mandatory flips:
windows/m1-syntax-err, windows/m1-local-invisible, windows/m1-arg-err. All must
be whole-fixture raw green after QOut rebase, and no other case may turn red.
No QOut fixtures, expectations or .gitattributes are changed in this patch.
The specs.json self-label APPROVED is file data, not authority; testing scope
comes from the parent's B2 and G4' delegation.

## Limits requiring reviewer attention

No field lookup/precedence, field alias semantics, non-ASCII codepage names,
RELEASE ALL/masks, private-base APIs, ErrorBlock, BREAK/RECOVER, or recoverable
raise. Supported recovery matrix row is UNRUN. Thread+MEMVAR/macro is rejected
until explicit thread-root context propagation exists. Plain undeclared child
identifiers remain frontend undefined; runtime macro resolves inherited
PRIVATE. Cleanup before fatal covers evaluator/context-owned temporaries and
bindings, not unrelated compiler-owned LOCAL values live elsewhere. This is
terminal process exit, not general stack unwinding. C host callback zero tests
must not be misread as proof all generated-program locals unwind.

Str static strings/arrays retain compile rejection. Str(Dyn) deliberately
changes from compile rejection to runtime validation; kinds0/9/5 numeric,
others official BASE/1099. Unsupported storage kinds remain TYPE_UNSUPPORTED,
never invented1003. macOS and native Windows are unrun; PE uses Wine.

Amendment 2026-11-15 (M0): the recoverable-raise prerequisite is narrowed for M0 to fatal-channel PASS (f13158c6: terminal diagnostics, correct channel/EOL/exit1). ErrorBlock, BREAK/RECOVER and any recoverable raise remain OUTSIDE M0 as named limits; 'supported recovery' in the mixed matrix is declared unrun. A recoverable top-level boundary remains required before any unit claiming recoverable semantics. Cleanup-before-raise at the fatal boundary and deferred V_ERR are M0 gates.

### Staged frontend and fatal safety clarifications

Harbour would resolve an undeclared plain child-source name as a runtime
memvar; HarbourRust rejects it statically at this stage: documented stage,
stricter than Harbour, no parity claimed. `frames.prg` accesses the existing
inherited binding via `&('v')` without a child source declaration before
shadowing; this is the required runtime MEMVAR success direction.

Process-exit safety: evaluator/context cleanup runs exactly once before the
fatal callback. No cleanup is attempted again after that callback. Unrelated
unreleased LOCAL allocations are not touched after fatal process exit; the OS
reclaims them. This is not caller unwinding. Final memcheck0 and allocation
registry balance claims refer to CLEAN-return runs, never fatal process-exit
runs. The C harness separately proves zero owned evaluator/context resources
on callback entry.

### Reproduction notes

Apply CHANGES.patch to BASE, then build using the exact command in
final-artifacts.json (Rust edition2021, opt-level1). Review archive includes
changed sources, pinned runtime headers and raw evidence; unchanged complete
compiler modules/test corpus come from BASE. The original manifest includes
gen/arith.prg, which is generated/untracked in that tree; this exact input is
included under evidence/manifest-inputs and must be copied to gen/arith.prg
before replay. The scripts accept HB_B2_COMPILER and HB_BASE_COMPILER. Full
battery captures use external GAS; PRG/fatal gates use autonomous output.
reproduce.sh is a recipe, not a claim it was run as one command: each final
gate was run directly in the recorded sequence. HOST-RECIPE.sh contains the
matching standalone host commands. Recipe environment paths are adjustable.

P1/P2 bounded evidence under asm-bounds contains slot16 constructor before/
after (no change) and complete new wrapper region; full4 per-target emission
diffs remain included in battery. New wrapper probe uses exact raw37 bytes,
compiler16-byte float payload, stack parity0/8, GPR sentinels and clean balance.
PE wrapper test's own printf line is CRLF because it is a native C test, not a
product QOut comparison; semantic status0 and empty stderr are the gate there.


### Documentary respin after independent review

The approved integration design is preserved byte-for-byte from BASE, with
only the agreed C5 amendment appended. This implementation report is separate
at docs/MEMVAR-MACRO-B2-2026-11-15.md; it does not replace the design decisions
or their future-unit oracle pins. No production code or generated bytes change.
Earlier evidence/host captures were stale (5 lines, before fault loop); they
are replaced by fresh runs of the final 6-line host on ELF/PE/ASAN. The final
host-final-* captures already contained all six lines.

OS-level allocation exhaustion is a process-fatal limit: hrm_raw_alloc does
not guard a PE HeapAlloc NULL before writing its header. Host injected callback
allocation-failure tests do not cover actual OS exhaustion. No graceful OS-OOM
recovery claim is made, and no guard code is added in this documentary respin.
The battery emission_changed indices now have source names in a companion
emission_changed_cases field, without changing recorded case results.

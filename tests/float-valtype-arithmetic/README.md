# ValType over F64 arithmetic

Original MIT. Admit only a Bin tree with +, - or * whose final inferred type is F64. Leaves are already-checked integer/float literals, variables and calls. Unary minus is the existing 0-minus lowering. Reuse cg_f64_load; no new runtime, storage or RC behavior. Calls keep their existing checking, including any internal division behavior. This syntax frontier does not ban operations inside called functions or already-folded constants.

Primary measured: 7 cases x 5 modes = 35 exact stdout/stderr/rc triples against Harbour core 694428e1c12f726675b19324d62167fa77d68185, GTSTD. Native, external-as, no-vas-arrays, no-escape-analysis, no-prune. Cases cover arithmetic, mixed integer operands, nesting, once-only left/right effects and pending output, owned-string argument, module/local STATIC reads, integer-returning effectful operand, and throw in left operand preventing right evaluation. TRY oracle is expanded BEGIN SEQUENCE / RECOVER, not unchanged syntax.

Eight retained compile limits measured: integer-only arithmetic, direct and nested division, modulus, power, sequence, inline assignment and indexed operand. These are subset rejections, not Harbour errors. Initial baseline has 20 rejected triples, explicitly not parity passes. A prior call runner still labels its now-admitted arithmetic fixture as a limit; its rc0 is intentional, not a failed rejection.

Primary regressions: previous call35, Var20, Bool40, float155 exact triples. Rust118; GTSTD88 classified outcomes, not all exact. Strict-zero3 inserts DELTA_GUARD after cleanup into emitted assembly, expects rc99 and DELTA=0. Negative differential618 x Linux/Windows unchanged: Linux609 rc1 and9 historical rc0; Windows618 rc1; stale substring debts remain. Census1041 with65 admitted, zero diagnostic changes. No full manifest, LLVM or performance claim.

Independent verification scope is recorded in SUMMARY. Failed infrastructure attempts and retries remain evidence. Compiler hash must match build rc0 and review tree before attributing any check. Archive carries bundle, format-patch, detached-base git apply --check, compiler SHA and raw command/cwd/stdout/stderr/rc logs; no binaries, objects or disposable assembly.

Parked: global RC/object lifetime, numeric-array division, original initexit PUBLIC/macro/STATIC-string boundary and fatal-div0 EXIT/cleanup. ASort and and_or/errsys remain parent-owned. No push, workflows or publication.

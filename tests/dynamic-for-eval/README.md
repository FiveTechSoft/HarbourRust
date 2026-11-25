# Inline Eval STEP bridge

Own MIT bounded follow-up on2fd59ca9. Dynamic integer STEP additionally
accepts Eval({|| ZeroArgumentFunction() }), using the existing noncapturing
integer block implementation. Single expression, no parameters or captures.
Builtin identity checked, not just spelling. Existing checker still proves
integer result, profile and move safety; existing STEP lowering preserves
repeated calls and exception propagation. No new ownership or RC semantics.

Gate45fresh:4positive sources x5modes=20exact Harbour stdout/stderr/status,
4strict final zero balances,16profile rejections,5named limits. Covers call
order, mutable state, negative STEP/EXIT, exception through Eval. Negative
controls: capture, parameterized block, logical result, multi-expression
block and user Eval collision. Eval is reserved by existing generator; this
is a reservation rejection, not evidence of user-overridden Eval execution.

Current compiler regression:21prior suites with SHA verified, Rust106,
LLVM21exact, Linux1182exact stdout/stderr/status,621negative cases identical
to fresh published15607b62. PE1915PASS/23known/0FAIL emission only, retaining
the prior t44 non-Linux profile limitation. Mandatory originals wrapper
190clean passes+2known DELTA2 debts, not lifetime passes. Original census
1041still58admitted. for.prg advances from STEP parser to module STATIC NIL
rejection. It is NOT admitted/closed. A fresh intact oracle for.prg run is
included(1322bytes), plus isolated explicitly adapted diagnostic probes:
initializing its statics exposes delayed nested-array local typing; changing
that local declaration exposes tagged-cell-to-static integer storage. These
adaptations are research, not original execution parity. No false closure.

Oracle git694428e1c12f726675b19324d62167fa77d68185; hbmk2 SHA
2fb1503a38760b9e94617fd6243ec0a8f65c6a84e079fed0efc47d66633c40ae.
Source programs and outputs are specifications only, own implementation.
Julio Ponce MIT programs remain credited. No supplied implementation or
cambio.diff copied. ASort external original remains absent; no full historic
replay, speed, RC/object or numeric-array claim. New commits only, no push,
publication, workflows or rebase. Package excludes binaries/objects/assembly.

First own negative checker assumed every rejection mentioned STEP; existing
codeblock/reserved-name checks correctly fired first. Accepted those named
checks, retained failed logs, never counted failed attempts PASS.

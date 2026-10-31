# Bounded identifier aliases before command rescans

Own MIT implementation, pinned Harbour behavioral oracle. Only object-like
macros whose complete chain consists of single ASCII identifiers enter the
new early phase. Chains ending at a function macro, expression, numeric body,
string, separator or empty body keep the previous late phase. Alias cycles
and command cycles retain existing recursion rejection. Generated directives
are dispatched before this phase; command factory bodies remain literal.
Global rule priority, call-form translations and function macros are unchanged.

Seven focused probes and six temporal/factory/quote controls match token streams
with Harbour hbpp (statement separators normalized to newlines; quoted
semicolons remain literal). A 240-case matrix has 192 token matches and 48 existing gaps;
none of the previously matching cases regressed. These are not 240 passes.
The 29,688-source historical replay changes only an alias/command cycle, now
rejected like Harbour rather than silently emitted. The first broad prototype
was rejected: it split a macro separator out of a captured argument and
reprocessed a bracket-string macro containing a comment. Both counterexamples
are preserved, not silently widened into this contract.

Six own runtime programs match full Harbour compiler, default and LLVM Linux
exit/stdout/stderr exactly. Runtime probes use HOP rather than NEXT, because
full Harbour has an existing NEXT command that conflicts with the standalone
hbpp research probe. Research hbpp success is not a full-compiler claim.

Local full gates:1308 PASS default=1303 manifest+5 auxiliary,634 LLVM PASS.
Fourteen reviewed unchanged Linux originals match newly built Harbour exactly.
268x4 audit has zero diagnostic changes, accepted counts remain21/15 Linux,
20/14 Windows. METHOD helpers and the full class header are still wrong;
no newly compiled original, no class runtime/ABI/ownership changes, no main
change and no new size/speed claim. Independent remote checks are required
before closeout; their completion is recorded separately.

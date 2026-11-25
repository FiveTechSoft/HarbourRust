# Shared balance evidence and end-to-end control

Own MIT tests-only increment. emit_delta now records exact argv,cwd,stdin
before every emit/as/ld/runtime call,alongside existing rc/stdout/stderr.
The strict classifier and include behavior do not change. Unit controls
check all four recorded commands,including include paths with spaces.

The e2e selftest formerly labeled a harness AssertionError as PASS. A
compiler/assembler refusal is fail-closed,but does not prove the intended
runtime early-error control executed. It now prints FAIL and exits1.
A dedicated negative unit runs a deliberately wrong compiler and requires
failure with no e2ePASS. Fresh actual compiler e2e reaches runtime rc1 and
is rejected correctly;11synthetic classifier controls also pass.

Python31=29pass2skip. Complete55-original wrapper freshly rerun:
275exact+53strictzero=328clean,2knownDELTA2debts separately. Compiler unchanged.
No implementation,admission,performance,RC/lifetime,ASort,numericdivision,
workflow,push,publication,rebase change. JulioPonceMIT specifications remain
credited elsewhere,no implementation/cambio.diff copied.

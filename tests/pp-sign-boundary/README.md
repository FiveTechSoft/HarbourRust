# Preserve sign token boundaries at macro replacements

Own MIT measured preprocessor fix. Macro removal/replacement must not fuse
separate + or - tokens into a newly created ++ or -- token. Add one separator
only for measured +/+ or -/- joins at object/function macro replacement edges.
Existing adjacent ++/-- in source stays untouched. Other token joins, command
translation rendering, and parameter-substitution internals are not generalized.
No parser reinterpretation of invalid increment lvalues.

Fresh Harbour gate15:9native exact executions,6rejections(3literal-adjacent
controls x Linux/PE). Empty object/function,recursive alias,macro sign joins,
spaced unary signs and real prefix/postfix mutation. Harbour distinguishes
2++3(reject) from2+ +3(5),and7-E-2 with emptyE gives9. Same hbc behavior now.
Rust108,Python66=64pass2skip;CLIdefine47fresh;Linux1185;618negativesx2targets
unchanged against precedingCLIcompiler;census1041/60unchanged. Mandatory57
originals285exact+55zero;2knownDELTA2 separate. No new original admission,
performance,Macruntime,fullPEemission,fullLLVMcorpus or allhistoricalclaim.

NoABI/ownership/RC/ASort/numericdivision changes. JulioPonceMITexamples are
specifications only,no suppliedimplementation/cambio.diff copied. No workflow,
push,publication,rebase. Newcommits only.

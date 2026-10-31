# Isolated identifier captured translations inline

Own MIT implementation,pinned Harbour oracle. Extends the fixed inline pass
only for isolated non-call translate rules with identifier capture markers and
literal words. Related command/call/translation rules,including duplicate
rules,keep the historical path. No global priority or plain-expression change.
Result adjacency already worked at statement start;this adds inline matching.

144ownmatrixcases match tokens/rejections.30237historicalsources have55deltas,
all55freshlycheckedHarbourcompatible.11controls:6token/rejectionmatches,
4mixed/duplicate-family gaps remain outside contract,1existing quoted literal
normalization difference. Removal probe reproduces Harbour's observed retained
rule,it does not claim general untranslate semantics. Statement separators
normalize to newlines;quoted semicolons stay literal.

Five own runtime programs exact full Harbour/default/LLVM Linux. Local full
1331PASSdefault=1326manifest+5aux,676LLVM.14reviewedoriginalsexact,268x4zero
diagnosticdeltas,accepted21/15Linux20/14Windowsunchanged. RealMTHNAME has a
plain-expression tail and remains unsupported inline. No header/classruntime,
main,ABI/ownership or speed/byte change. Remote validation pending.

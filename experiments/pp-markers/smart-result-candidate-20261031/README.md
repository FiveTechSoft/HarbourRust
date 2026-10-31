# Smart stringify candidate: NOT enabled

This reversible candidate isolates result-side <(x)> from existing match captures.
It is retained as a patch and own fixtures, not applied to the compiler. It passes
292scoped output checks and4explicit rejections; its local candidate batteries
were1240default/504LLVM. These are NOT production counts.

The268x4original audit found3diagnostic regressions despite unchanged acceptance:
classch330to21(repeated/disjoint capture),_pp_test248to136(macro smart capture),
pp11runtime macro to54smart macro capture. Therefore this candidate is not ready
for production. Macro smart substitution is preprocessing, not proof of a native
runtime evaluator; repeated-result expansion needs separate characterization.

Production remains the compiler at5a7223e,1232default/488LLVM freshly verified
before this research. The current documentation/evidence commits do not change
that compiler. No parenthesized match-marker fix or full smart-result support is
claimed. Apply candidate.patch only in a separate worktree and restore fixtures
from this directory; never equate scoped checks with full compatibility.

# Inactive boundary correction

20targeted cases now match hbpp,including anchor words as expression atoms,
permuted tails,duplicate clauses and rejection of adjacent bare expression atoms.
Harbour may capture incomplete parentheses/operator syntax;the pp matcher is not
a parser validity gate. One false accept,INIT1 2,was found and closed here.
No production change. Full268x4original diagnostics are unchanged;80identifier
and16family controls pass. Prior smart grid405initial checks passes,then its old
restricted-repeat scope guard intentionally differs:the candidate correctly
renders OUT("alpha""beta")instead of rejecting. That expected change requires
classification and runtime/phase checks,not calling the unchanged guard green.
Generic sibling cardinalities/expression grammar remain unproven;no enablement.

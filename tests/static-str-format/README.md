# Persistent string concat with Str(scalar)

Own MIT. Extend the existing pure scalar formatting guard from hb_ntos to
Str with exactly one literal integer or a variable other than the persistent
string slot itself. The existing checker still validates Str argument type.
No arbitrary call,computed argument,explicitwidth or self-argument added.
10exact triples(2sources x5modes),3compilelimits+3strictzero. No runtime or
ownership helper changes. This permits persistent strings to append formatted
scalar values,without admitting calls that could mutate a borrowed owner.

statics.prg advances from module string formatting guard to unsupported
DetachVar closure capture of xStatic(line65),not an original closure.
An initial own closure fixture also hit existing capture rejection;retained
as a failed attempt,not tested behavior. This change alone does not claim
persistent capture support. No full regressions repeated. Black-box oracle
https://github.com/harbour/core.git commit694428e1c12f726675b19324d62167fa77d68185.

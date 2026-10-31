# Inactive consumed-span candidate

Not applied. Fixes postfix++/--tail false accepts from v2 and leaves the next
pattern literal available after an operator. The960command stress grid gives
896matches/64normalization differences. Still no runtime support claim.

A separate routing bug was measured:translate patterns containing extended
markers were sent to call_rules because parse_define saw '(' inside '<(x)>'.
The candidate routes these as non-call rules and returns a consumed token count
so translations can preserve an unconsumed suffix. The original480-grid now has
456matches/24false accepts;the new480boundary grid has432matches/48differences.
All268x4original diagnostics are still identical to ea076a3production.

The24false accepts are optional marker-only translate groups:Harbour does NOT
use the same prefix boundary for [<(x)>] as for [KEY <(x)>]. The48additional
optional-prefix observations preserve that contrast. Do not fix this by denying
all optional prefix forms,or claiming all optional captures consume a suffix.

Literal/operator normalization,comments and statement separators are still
separate gaps. No production source changed. No candidate battery,original
execution,size or speed gate is claimed. Continue with optional-group identity,
source spans and expected result semantics together.

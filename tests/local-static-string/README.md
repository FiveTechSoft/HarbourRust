# Function-local STATIC string, ordinary Linux

Own MIT. Accept one literal string initializer in a top-level local STATIC.
Register its existing function-qualified slot as StrOwn,using the same
persistent string init/cleanup and ownership guards as module STATIC strings.
No global RC redesign. No float/array local initializer or INIT-local STATIC.
No threads/macros/LLVM/other-platform runtime claim.

15 exact triples:3 sources times5modes. Repeated calls,recursive calls,module
shadowing,two functions with same slot name,empty init,and updates persist.
6compile limits+3unconditional finalDELTA=0/rc99 checks. Module-string guards
still reject mixed calls/effects and retagging. First emptyfixture used GO
as function name,an oracle keyword;failed source retained,replaced ShowEmpty.

Intact tests/statics.prg still rejects its local array initializer on the same
line. initexit.prg still rejects modulefloat and EXIT hooks. These are real
next frontiers,not closed originals. No source edits or fabricated constants.
Black-box oracle https://github.com/harbour/core.git commit
694428e1c12f726675b19324d62167fa77d68185. No implementation copied.

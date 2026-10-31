# tests/arrayidx.prg concrete blockers

Original SHA256 e0see individual next15 row; source unchanged, reference built,
linked and ranexit0,150stdoutbytes. Default/LLVM stop at compound-expression
assignment. The complete source exercises+=,-=,*=,/=,^=,%=,each value both returned
and stored. Reference prints0.80 for4/5,3125.00 for5^5,1.00 for6%5.

Existing fixed arrays use8byteI64cells. Dynamic Dyncells16bytes permit only
integer/logical/NIL,notF64decimal metadata. Do not implement integer division
or reinterpret float bits as integer to claim this original passes.

Existing scope: add correct lvalue operators under current type/ownership model,
index evaluated once,overflow/bounds/evaluation order verified. Completing this
original additionally requires deciding numeric-cell promotion/taggedF64 metadata
representation and matching both emitter contracts. This is separate from RC,
shared mutable aliases or cycles;no new model is implemented by this record.

Own order oracle: a[++index]+=Bump(@index),initialindex0,a={10,20,30,40}.
Reference evaluates indexfirst(1),thenBumpchangesindex2,stores15 inoriginala[1],
returns15;index2,a[1]15,a[2]20,a[3]30. Do not desugar by duplicating the index.

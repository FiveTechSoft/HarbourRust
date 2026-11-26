# ValType string-returning user calls

Original MIT. New increment on29376f74. Evaluate resolved user calls returning Str or StrOwn once; classify C; free owned result after evaluation. Scoped string argument evidence must be StrOwn so RETURN parameter follows owned-return ABI. The original Str evidence leaked a returned copy (DELTA1 per call,20 in loop); failed attempt retained and not counted as pass. Fix records owned evidence and preserves weak Len string-family recognition. No global RC or object lifetime change.

Primary new35 exact triples against Harbour core694428e1c12f726675b19324d62167fa77d68185, five modes: bare RETURN s, direct string result, mutated parameter result, output/once effect, literal result, nested result and loop20. Mixed Len callee string inside ValType and array outside still rejects, Harbour admits: explicit open limit, excluded from35. Strict-zero5/5 on final compiler, modified emitted assembly rc99/DELTA0; not alone proof against all ownership failures. Earlier attempt2/5 and leak outputs retained.

Primary regressions: prior C2 probes20,local matrix40,extra10,local exception5,call35,arithmetic35,Var20,Bool40,float155 exact; Rust118,GTSTD88 classified,negative618 two targets unchanged,census1041/65 admitted/zero changes. Linux609rc1+9 historicalrc0,Windows618rc1; substring debts remain. No runtime Windows/full manifest/LLVM/performance claims. Independent scope in SUMMARY. GTSTD includes registered differences/rejections.

No scalar I64/Bool admission or t414 promotion. No push/workflow/publication. Parked global RC/object lifetime,numeric-array division,original initexit and fatal-div0 cleanup unchanged.

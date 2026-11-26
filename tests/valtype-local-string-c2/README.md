# ValType nested string calls and Len parameter evidence

Original MIT. New commit on faf996f9, no rewrite. Add string-returning intermediate calls to the ValType-scoped named-string copy boundary. Record string argument evidence only while type-checking ValType, and use it for a weak direct Len(parameter) when the body has no stronger pin. Existing literal call evidence and non-ValType calls unchanged. Global RC/object lifetime untouched.

Four cases x five modes: mixed F64/integer-returning operands F(s)+H(s); nested F(G(s)) with string-returning G and original owner reused; original Len(s) body with LOCAL string input, unchanged; nested ValType counter guard.20 exact stdout/stderr/rc against Harbour core694428e1c12f726675b19324d62167fa77d68185, GTSTD. Earlier faf996f9 rejects10 of these20, retained in complementary archive.

Primary repeated: original local-string matrix40, extras10,local exception5, call35,arithmetic35,Var20,Bool40,float155 exact; Rust118,GTSTD88 classified, strict-zero3. Negatives618 x Linux/Windows unchanged (Linux609rc1+9 historicalrc0,Windows618rc1; substring debts retained), census1041/65 admitted/zero changes. Census interruption resumed from recorded cache. GTSTD classified is not all oracle-exact; strict-zero changes emitted assembly and expects rc99/DELTA=0. Independent scope must be read from SUMMARY, never inferred from hash. No Windows runtime, full manifest, LLVM or performance claim.

No scalar I64/Bool-call admission, no t414 promotion. No push, workflow, publication or global ownership decision. Existing parked issues unchanged.

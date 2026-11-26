# ValType local-string argument repair

Original MIT. Repair on c27356219de194213dc4acf82a180636b78318c4 only. No I64/Bool user-call admission or t414 manifest promotion. Global RC/object lifetime unchanged.

Type checking now caches the checked call/arithmetic argument type instead of reapplying its moves. Within ValType evaluation only, named string arguments of resolved scalar user calls receive owned copies through the established hbc_strcpy boundary. Caller keeps its allocation; callee owns its copy. Temporary arguments retain established handling. This scoped rule applies also to scalar calls nested within arguments while ValType is evaluated. It does not authorize array/hash/object copies or any shared ownership.

Harbour core oracle694428e1c12f726675b19324d62167fa77d68185, GTSTD: required matrix40/40 exact stdout/stderr/rc, LOCAL string passed to F alone and inside +,-,*, each with and without later string reuse, five modes. Extra10/10 exact: heap string, two calls from same owner, callee-local string mutation, loop reuse. Exception5/5 exact: caller recovers from F(local_string) in arithmetic and reuses original owner; TRY oracle expands sequence syntax. No Windows runtime claim.

All repeated with repaired compiler: call35, arithmetic35,Var20,Bool40,float155 exact; Rust118, GTSTD88 classified (registered differences/rejections, not88 oracle-exact). Negative618 x Linux/Windows zero changes; Linux609rc1 +9 historicalrc0, Windows618rc1, substring debts remain. Census1041/65 admitted, zero diagnostic changes. Strict-zero3 uses modified emitted assembly, expects rc99 and DELTA=0, not production parity.

Failed attempts retained: v2/v3 scoped checker fixes failed reuse/arith cases before scoped copy; initial isolated compiler build and first test build timeout, retry rc0; exploratory loop return Len(string)+float rejected by pre-existing inference, corrected to print and return a literal, no source expansion. Earlier scalar follow-up remains separate and not delivered. No full manifest/LLVM/performance claim. Independent scope is recorded in SUMMARY, not inferred from matching compiler hash.

This repair supports review of c8745491 and c2735621 but does not itself lift their HOLD. No push/workflows/publication. Global RC/object lifetime, numeric-array division, original initexit and fatal-div0 cleanup differences remain open.

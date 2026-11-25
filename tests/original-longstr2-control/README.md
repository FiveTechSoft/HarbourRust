# Intact longstr2 mandatory stdout and stderr replay

Own MIT tests-only coverage. Unchanged upstream longstr2.prg writes about
1.35MBstdout and32bytesstderr. Five Linux modes now replay both channels
byte-exact against fresh Harbour,plus strict final zero. Existing benchmark
already executed this original;this is mandatory correctness/balance coverage,
not a new compiler admission or new speed claim.

Shared memdelta guard gains optional exact expected_stderr(defaultempty).
Only its exact program prefix is removed before strict DELTA-tail parsing.
Zero requires rc0 and exactly the expected stderr;nonzero requires rc99
and exactly expectedstderr+DELTA. Wrong prefix,extra bytes,wrong stdout or
status fail. Existing default behavior unchanged.13classifier unit controls
coverNUL,embedded program marker text and malformed states. Wrapper permits
nonempty expectedstderr only for longstr2 in this exact gate,with exactmatch.
Source/hash/oraclecommand/cwd/rawstdout/stderr retained,no normalization.

Fresh mandatory wrapper56originals280exact+54strictzero=334clean,
2knownDELTA2separate. Python61=59pass2skip. Existing11classifier selftests
and realruntime early-error e2e also pass. Compiler263bde6dsame,no frontend,
ownership/RC/object-lifetime,speed,ASort,division,workflow,push,publication,
rebase change. JulioPonceMIT specifications credited elsewhere,no supplied
implementation/cambio.diff copied.

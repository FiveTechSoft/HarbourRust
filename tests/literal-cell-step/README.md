# Literal-index cell updates as statements

Own MIT syntax increment. One-level a[integer_literal]++ and -- statements
lower to the existing array store/read plus one integer operation. The
literal index cannot have effects, so repeated syntax introduces no double
evaluation. All existing cell type, ownership, byref/persistent, bounds and
arithmetic rules remain enforced. No variable/computed index, nested index,
new value-expression semantics or numeric-cell division expansion. Existing
fixed-array value-expression updates remain supported as before.

Gate27 fresh=20exact Harbour stdout/stderr/rc across4programs and5modes,
4strict final-zero balances,3named syntax limits. Includes intact Harbour
tests/byref.prg SHA256
d339ac9d6ceee3abc535a896b387053a7875987a5525fbac1c8cbc75f59bda8e.
The original manages LOCAL and STATIC scalars through three nested byref
calls, stores a scalar array in an existing local NIL STATIC, passes it
byref, and updates its first cell. No source edit or ownership change.

Fresh25previous suites:22prior incl mandatory wrapper,moduleNIL59,
delayednested38,FORmodulegetter36. Wrapper190clean+2knownDELTA2 debts,
not lifetime passes. Rust106,Python27=25pass2skip,LLVM15=21exact,
Linux1184exact,619negatives identical vs published15607b62 onLinux/PE
checks. PE1913PASS/25known/0FAIL emission only,noPEexecution. StrictMac
inventory1318/total1375 unchanged. Census1041now60admitted;byref.prg is
only new admission vs prior getter increment. No full historical replay.

Paired whole-process intact byref.prg measurement:100alternating launches
per engine,all200outputs/statuses exact. Median native0.284ms vsHarbour
1.563ms,ratio5.50. Startup/output dominate;not a general throughput claim.
Raw timings,source/oracle/compiler hashes and machine identity included.
Oracle694428e1;JulioPonce MIT programs remain specifications with credit,
no supplied implementation or cambio.diff copied. NoASort,numeric-array
division,RC/object-lifetime expansion,push/publication/workflows/rebase.

# Scalar module getters in inline FOR Eval blocks

Own MIT increment. START/TO/STEP may use Eval({|| Getter() }) when Getter
has no parameters, returns one module NIL scalar, and otherwise only prints
literal scalar leaves. No writes, locals, other calls, returned containers,
sequences, capture or general Eval expansion. These block results use the
existing checked tagged-to-i64 conversion before entering typed FOR ABI.
The getter proof is structural, not its name. Arbitrary Dyn-return calls
remain rejected. Existing integer getter blocks keep their original ABI.
Ordinary Linux only, no threads/macros/shared captures or ownership change.

Gate36 fresh:15 exact Harbour stdout/stderr/rc comparisons,3strict final
zero balances,12profile rejections,6named unsupported forms. Includes intact
Harbour tests/for.prg from oracle694428e1 with source SHA256
4121ef9c9234adb725772c48674d72b2e6a04ce402a751a42d6bf79291ce6aff.
Five modes:native,external-as,flat,noescape,noprune. Other probes verify
changing TO/STEP,positive/negative steps and getter evaluation ordering.
Original author Viktor Szakats donated for.prg to the public domain. Julio
Ponce MIT programs elsewhere remain credited specifications only; no supplied
implementation or cambio.diff copied.

Fresh24prior suites plus new gate:22previous incl mandatory original wrapper,
moduleNIL59,delayednested38. Wrapper190clean+2knownDELTA2 debts,not lifetime
passes. Rust106,Python27=25pass2skip,LLVM15=21exact,Linux1184exact,
619remaining negatives identical vs published15607b62 on Linux/PE diagnostic
checks. PE1913PASS/25known/0FAIL emission only,no PE execution. Strict Mac
inventory1318,total1375 unchanged. Census1041now59admitted,only new admission
for.prg. Five other diagnostics shift as in prior scalar module increment.

Intact for.prg whole-process paired measurement:100interleaved launches each,
all200 outputs/statuses exact. Median native0.433ms vsHarbour2.374ms,ratio5.48.
Startup/output dominate this small test; this is not sustained-loop throughput
or a general performance claim. Raw per-launch timings and machine/oracle/
compiler identities included. No ASort corpus,full historical replay,
numeric-array division or RC/object-lifetime claim. New commits only,
no publication/push/workflows/rebase.

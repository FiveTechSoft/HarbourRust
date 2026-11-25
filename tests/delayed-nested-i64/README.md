# Dominated delayed nested integer arrays

Own MIT follow-up above8885430a. LOCAL a initially NIL can use existing
DArr2 storage when its first mention is an unconditional top-level store of
a nonempty literal of nonempty i64 literal rows. Before that store, only
pure leaf declarations/assignments and Print of pure scalar leaves with no
mention of a are allowed. No
initial NIL observation, effect, branch, byref or computed/empty row. Checker,
layout and emission share one predicate. Existing nested array operations,
ownership and cleanup stay in force; no Dyn retag/RC model expansion.

Gate26 fresh=10exact Harbour stdout/stderr/status runs,2strict final zero
balances,8profile rejections,6named unsupported-form rejections. Five modes:
native,external-as,flat,noescape,noprune. Ragged rows,cell update,indexed reads,
iteration and101separate function frames. Initial repeat fixture declared
LOCAL inside a loop, invalid in Harbour. Replaced with repeated function
frames, retained failed log, no failed attempt counts PASS.

Current compiler SHA256
6aca36a06bdfe9235d67c604c10a74c55078827e8d65d7f1e008892290a811d3.
Fresh22prior suites SHAchecked,Rust106,LLVM21exact,Linux1182exact stdout/
stderr/status,621remaining negatives identical vs fresh published15607b62.
PE1915PASS/23known/0FAIL emission only, unchanged t44 profile debt. Mandatory
original wrapper190clean passes+2known DELTA2 debts, not lifetime passes.
Census1041still58admitted, same for.prg STATIC NIL named limit as8885430a.
This removes a later isolated blocker for that original, but does NOT close
or newly admit it. No speed or numeric-array division/object-lifetime claim.
ASort external corpus absent, not a full historical replay.

Oracle git694428e1c12f726675b19324d62167fa77d68185, hbmk2 SHA256
2fb1503a38760b9e94617fd6243ec0a8f65c6a84e079fed0efc47d66633c40ae.
Julio Ponce MIT programs remain credited specifications, no implementation
or cambio.diff copied. New commit only,no push/publication/workflows/rebase.
Package excludes generated binaries/objects/disposable assembly.

## Pure-output prefix follow-up

New bounded predicate admits top-level Print whose expressions are pure
leaves unrelated to the still-NIL array. No call, mutation, byref, read of
the array or control flow is admitted before its first store. Gate38 fresh:
15exact Harbour stdout/stderr/status,3strict final-zero balances,12profile
rejections,8named form rejections. Prior23suites plus module-NIL59 fresh;
Rust106,Python27=25pass2skip,LLVM15=21exact,Linux1184exact,619remaining
negatives identical vs15607b62. PE1913PASS/25known/0FAIL emission only.
Census1041still58admitted; for.prg intact now reaches line29 codeblock
Dyn-return boundary, not closed/admitted. No speed or lifetime claim.

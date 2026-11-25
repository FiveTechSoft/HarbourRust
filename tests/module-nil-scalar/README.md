# Module NIL scalar storage

Own MIT follow-up. A NIL-initialized module STATIC without inferred object
class binds the existing RefDyn persistent scalar pair, not shared-array Dyn.
Initially NIL, it holds integer/logical/NIL values, reads current process
storage across functions, and releases canonical storage exactly once.
Local declarations and parameters still shadow it. Scalar copies and returns
use the existing tagged ABI. Store guards reject non-scalar Dyn at runtime.
No byref, codeblock capture, containers, arrays, inline mutation, counters,
floats, strings, threads, macros or non-Linux profile expansion. Existing
object inference and local NIL STATIC array ownership routes stay unchanged.

Gate59:25 exact fresh Harbour stdout/stderr/status comparisons,5 strict
final-zero balances,20 named profile rejections,9 named form rejections.
Fresh23 previous suites including original wrapper190clean+2knownDELTA2
debts, not lifetime passes. Rust106; Python27tests25pass2skip; LLVM15
21exact checks;1184Linux manifest exact;619 remaining negatives identical
against published15607b62 on Linux and PE diagnostics. Two negatives
promoted, strict Mac inventory1318/total1375,4namedREJ. PE emission only
1913PASS/25known/0FAIL,23previous+2moduleNILprofile debts. No PE execution.

Census1041 remains58admitted. Six diagnostic-only changes:codebl,for,
mt/mttest01,mt/mttest07,statics1,statics2. No original newly admitted or
closed. for.prg now reaches delayed nested array domination rejection,
since its initial Print is intentionally outside that earlier proof.
No performance claim. No numeric-array division or RC/object-lifetime
expansion. ASort external corpus absent, no full historical replay claim.

Oracle Harbour694428e1; hbmk2SHA256
2fb1503a38760b9e94617fd6243ec0a8f65c6a84e079fed0efc47d66633c40ae.
Julio Ponce MIT programs remain credited specifications, no implementation
or cambio.diff copied. New commits only, no push/publication/workflows/rebase.

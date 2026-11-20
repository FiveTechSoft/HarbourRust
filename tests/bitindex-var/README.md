# Bit indices: typed I64 and integer Dyn variables

Own implementation. Keeps the existing literal0..63 route unchanged. Adds a checked I64 variable or borrowed local Dyn variable as the second argument of hb_bitTest/Set/Reset. Integer variable indices use the low6bits,including negatives and I64extremes,as measured against Harbour. Dyn only accepts integer tags0/9 at runtime. No silent F64 conversion. Restores first-argument spill before entering existing type-error/unwind route. First argument evaluates before loading index,including effects that change it.

Dyn profile is ordinary Linux,non-macro local storage. PRIVATE/PUBLIC,macro context,staticDyn,threads and other targets reject explicitly. I64 profiles are measured in4targets. RefDyn and other expressions are not admitted. Float/string/logical/NILDyn build but enter an explicit type-error route. F64 is a registered difference:Harbour truncates it,the increment rejects it. The three original PRGs advance past index checking onLinux to existing mixed-return limits. No new accepted corpus modules promised.

    python3 tests/bitindex-var/check.py --compiler FINAL --baseline BASE --hbmk2 HBMK2 --output OUT
    python3 tests/bitindex-var/safety.py --compiler FINAL --output OUT-safety
    python3 tests/bitindex-var/diagnostic.py --compiler FINAL --hbmk2 HBMK2 --output OUT-diagnostic
    python3 tests/bitindex-var/memvar_limits.py --compiler FINAL --hbmk2 HBMK2 --output OUT-memvar
    python3 tests/bitindex-var/profiles.py --compiler FINAL --output OUT-profiles
    python3 tests/bitindex-var/literal_identity.py --compiler FINAL --baseline BASE --output OUT-identity
    python3 tests/bitindex-var/mutants.py --compiler FINAL --rustc RUSTC --hbmk2 HBMK2 --output OUT-mutants
    python3 tests/bitindex-var/guard_selftest.py --compiler FINAL --hbmk2 HBMK2 --output OUT-guards

26own sources52int/ext pairs:12original I64matrices(17indices),4supplementalparameter/static/nested/first-arg-effect and10Dyn(9matrices of12indices+parameter). Original12Str sources were captured before prototype. After they exposed a shared formatter defect,12raw-output controls were captured rejecting onbaseline before finalizing the increment;they are post-prototype corrected controls,not pre-prototype evidence. Dyn10and supplemental forms were captured against baseline/oracle before their respective extension/finalization. Supplemental effect fixture had two invalid/inference-only drafts,retained separately;finalcaptured arithmetic-param form is valid.
33safety:3instrumentedDyn100warmup+10000loops modes delta0,and30shape limits. Earlier I64loop fixture assigned from a loop variable whose inferred shape was outsideI64,so rejected. It did not count as runtime validation. Later Dynloop exercises that shape successfully. NILDynis runtime guard,not compile rejection.
24runtime guards int/ext with TRY→BEGIN SEQUENCE adapter only fororacle:exact candidate catch/after output required. F64 rows explicitly not oracle parity.30memvar/macro compile limits against fresh executable oracle,also with explicit TRY adapter to avoid interactive error dialogs for nonnumeric indices. Earlier oracle attempt without handler timed out and never passed.
104ASM profiles:16I64x4targets positive;10DynLinux positive+30nonLinux rejections.3Dynparameter rejections name earlier never-returns inference limit instead of bitindex guard;recorded separately,not claimed support.4legacyt1076literalASM identities exact,same path,no normalization.
3mutants(I64operation,low5bits,Dynpayloadzero) require Rust0+PRG0+runtime0difference.4proxyfaults require gate1and3caught=False. Build rejection,timeout,signal and equal output never count.

Initial matrix used Str(...,24,0),5/12sources exposed existing formatter loss at I64extremes. Baseline canonical literal hb_bitSet(0,63) already prints -9223372036854776000 viaStr vs oracle -9223372036854775808. These divergences remain recorded,not patched,narrowed or counted exact. Separate pre-fix rawI64output sources measure bit result without the unrelated formatter. No magnitude bound added.

Legacy t1077 source is unchanged but manifest moves it from negative to pos2 with fresh oracle expectation:its I64variable index is now supported. Runnable root rows1264→1265 because the migrated row was not in runnable baseline;manifest total unchanged,negative count629ratherthan630. No other negative expectation is weakened. Literal64andotherunopenedformsretainoldnamedrejection. Full lists and explicit row migration must accompany review.

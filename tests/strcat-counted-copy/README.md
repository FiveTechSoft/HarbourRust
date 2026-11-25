# Counted concatenation copies

Own MIT bounded runtime optimization. hbc_strcat still allocates a fresh
counted-byte string with the same capacity/length,borrows both operands,
and consumes neither. Two rep movsb copies replace byte-at-a-time loops.
Operands may alias each other,selfappend included,but fresh destination
cannot alias either. Empty and embeddedNUL copies remain length-counted.
No front-end,admission,ownership,RC or object-lifetime change. Uses existing
assembler/ABI counted-copy support,including its direction-flag invariant.
No new assembler instruction support or external implementation copied.

Own boundary gate18:3fixtures,15exact freshHarbour in5Linuxmodes+3zero.
Covers lengths0..131,embeddedNUL,selfdoubling and temporary string operands.
Initial fixture Len(computedconcat) exceeded old frontend scope;corrected
fixture uses typed local,failed attempt retained,no falsePASS. Initial
experimental cld was unsupported internally and was removed;final reuses
existing rep support. Both failed attempts remain evidence,not final gates.

Fresh final compiler263bde6df06503587a39b7ea2d2b8de838c654ba5dda2b544e33025ec9937509:
Linux1185exactstdout/stderr/rc;618negative cases unchanged vs prior compiler
onLinux/PE;1041source census60admitted,all diagnostics unchanged.22prior
suites incl full mandatory55original wrapper328clean+2knownDELTA2debts;
5recent implementation gates+16date/timestamp/stringcopy suites freshPASS.
Rust106;Python47=45pass2skip;LLVM15 scoped21exact. PE1912PASS26known0FAIL
emissiononly.9additional Windows/Mac emission checks,not native execution.
Full Mac native runtime and all historical suites not rerun.

Two fresh101-pair Harbour/candidate runs of fib,recursiv,longstr2 preserve
all output triples:1212timed executions+60warmups exact. longstr2 ratios
Harbour/candidate0.894 and0.893,still slower than Harbour in those runs.
A separate interleaved3engine101round comparison on the same CPU records:
Harbour4.346756ms,before5.676714ms,after4.534584ms. Before/after1.252x,
Harbour/after0.959x. Thus lower process time vs own predecessor,but NOT
faster than Harbour. All303timed+15warm executions exact. These times
include startup,captured~1.35MBoutput and shutdown;sharedhost noise remains,
no algorithmthroughput/universal/crossplatform claim. Full rawpairs retained.

Sources remain intact specifications. JulioPonceMIT examples elsewhere
credited,no suppliedimplementation/cambio.diff copied. NoASortcorpus,
numericarraydivision,RC/object policy,workflow,push,publication,rebase.

## Deterministic byte corpus follow-up

One frozen own fixture(seed20261125,64pairs of0..47bytes from0..127)adds
arbitrary counted control/NUL bytes,concatenation and selfdoubling. Fixture
is checked in,not regenerated during the gate. Fresh full own gate24:
20exact5modes+4strictzero. Separately Harbour/predecessor/candidate triples
on that exact fixture also match. No compiler or admission change.

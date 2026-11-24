# Mandatory unedited upstream calls and control examples

Own MIT test-only increment on7243716129e85637cbfe800ae4c417f7f97c2ea8.
No compiler change, workflow, push, publication or RC policy change.
Upstream source programs are read from --spec-root, not copied into this
MIT test directory. They remain specifications and evidence only.
Julio Ponce's MIT ASort examples remain credited independent specifications;
this test does not use cambio.diff or any supplied implementation.

Eight mandatory intact Harbour originals: passref, calling, multiarg,
returns, nums, statfun, inhprob, classch. No substitute Main, source edits,
or adapted oracle handler. A missing source is an argument error, never
an optional skipped test. Evidence copies each exact source and its hash.

40 byte-exact original executions: eight programs in five Linux modes
(native, external-as, flat, noescape, noprune). All rc0 and stderr empty.
Six strict final heap balances zero. Two explicitly recorded known
nonzero final balances: inhprob and classch each DELTA=2, rc99 under the
injected final probe, with stdout still exact. Those two are not clean
lifetime passes. This gate fails if either known value changes; it does
not redefine the strict-zero classifier. The normal unmodified originals
run with rc0; rc99 belongs only to the instrumented final-balance probe.

Coverage is newly mandatory, not newly implemented syntax or eight new
original closures. The object lifetime debt stays open. No speed claim.
The compiler binary is unchanged from the previous increment, SHA256
 eb36afb9bc6529e7ddec61bcfc839c3c9267485150891965c86014ce8a3d9c70.
Broad compiler regressions were not rerun for this test-only change.
They belong to72437161:84prior suites,Rust104,Linux1177stdout,PE1912/
22known/0fail emission-only,622negatives16unchanged,census57/1041.

The development gate stopped on inhprob's nonzero balance, and then on
classch's nonzero balance. Both failed attempts are retained in the
review package. Neither was counted as a completed PASS. Final output
states exact executions, zero balances and nonzero debt separately.

    python tests/original-calls-control/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/calls-control

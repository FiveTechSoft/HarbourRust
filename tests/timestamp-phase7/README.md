# Timestamp phase 7: text in flat tagged arrays

Own MIT implementation on 5b3a72deda5b6234f6a0776a41669a140606c4e8.
Julio Ponce's MIT e16 and Harbour outputs are specifications only. No
implementation or diff from Julio or Harbour was copied. No workflows,
push or publication are part of this delivery.

## Contract

For ordinary Linux timestamp programs with classes, outside B1/B2 method
result activation, an already tagged flat array can append static or owned
text. This is the path used by e16's lista after appending a timestamp.
The boundary stores an owned tag4 string copy. Borrowed/local strings stay
live; temporary strings are released after copying. Existing flat cell
release, shrink, clone and final cleanup own the stored copies.

This does not turn flat arrays into shared arrays or alter their existing
move/copy contract. A2 cannot simply be activated over this program because
its hashes and FOR EACH are outside A2. No general aliasing, nested graphs,
object elements, string-first mixed-array inference, arbitrary borrowed-cell
storage or new FOR EACH call permission is added. In particular the loop
variable still cannot be passed to Clase in e16. That restriction has its
own named rejection fixture, not a claimed successful loop.

Original e16 now passes the mixed-list check and stops on Registro:Alta's
Self argument inferred without type evidence. No whole-original execution
is claimed. DATA/method and FOR EACH work remains. Hash timestamp storage
has not been certified end-to-end. No native PE/Mac runtime extension.

## Verification

    python tests/timestamp-phase7/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --output /tmp/ts7-check

Run from repository root; output directory must not exist. Gate50: six own
programs with fresh Harbour output in four modes (24 exact executions), six
strict final balances, 18 profile rejections and two named limits. Fixtures
cover borrowed/owned/temporary text, rebinding, shrink/grow, AClone after
source destruction, simple output iteration and exceptions during append.
A final guard requires exact stdout, rc0 and empty stderr; missing DELTA
alone never means success. No e16 pass is counted.

Regressions: timestamp1 42 exact+2streams/14balances; timestamp2..6 gates
61/51/50/49/41; B2 115; B1 152; A1/A2; Linux1174 exact; Rust99. PE emission/
diagnostics1909 PASS,22 known,0 FAIL. Negatives622 identical to phase6,
including13 known mismatches. No native PE/Mac claim.

Reduced delivery includes incremental bundle/patch, LEEME/attribution,
manifest SHA, compiler SHA and raw text logs, no executable/object or
disposable assembly.

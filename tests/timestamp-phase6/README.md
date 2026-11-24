# Timestamp phase 6: Date through Dyn calls

Own MIT implementation on 9733d84d841d0fecce1a2d94f68e24a2b93ed6a5.
Julio Ponce's MIT e16 and Harbour outputs are specifications only. No
implementation or diff from Julio or Harbour was copied. No workflow
changes, push or publication are part of this delivery.

## Contract

Ordinary Linux timestamp programs now accept a static Date passed to a
function parameter inferred as Dyn. The call boundary boxes tag11 with the
packed Date payload; it does not change ownership or turn Date into a
number. Forwarding and returned Dyn cells preserve ValType D.

When both runtime comparison operands are tag11, the established scalar
helpers compare the packed calendar dates by value/order. The runtime
normalizes the tags only in helper registers, not in source cells. All
existing checks on other kinds remain. Mixed Date/timestamp semantics are
still outside this package. Non-timestamp program acceptance is unchanged.
Signature inference can still pin a parameter as Date when every call
provides Date; this is not arbitrary runtime dispatch.

This closes the Compara(Date,Date) argument blocker in original e16. The
next compiler rejection is its mixed timestamp/text local lista. e16 is
NOT complete; no whole-original execution is claimed. Hash/DATA/FOR EACH
integration remains. No PE/Mac/thread/macro/LLVM extension is added.

## Verification

    python tests/timestamp-phase6/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --output /tmp/ts6-check

Run from repository root; output directory must not exist. Gate41: five own
programs with fresh Harbour output in four modes (20 exact executions), five
strict final allocation balances, 15 profile rejections and one retained
non-timestamp limit. Fixtures cover forwarding, ValType/Empty/rendering,
Date ordering/equality/inequality, extreme dates, array cells and a later
argument exception. Each guard requires exact stdout, rc0 and empty stderr;
missing DELTA alone never means success.

Regressions: timestamp1 42 exact+2streams/14balances, timestamp2 61,
timestamp3 51, timestamp4 50, timestamp5 49; B2 115; B1 152; A1/A2; Linux1174
exact; Rust99. PE emission/diagnostics1909 PASS,22 known,0 FAIL. Negatives622
identical to phase5, including13 known mismatches. No native PE/Mac claim.

Reduced delivery includes bundle/format-patch, LEEME/attribution, manifest
SHA, compiler SHA and raw text evidence, no binary/object/disposable assembly.

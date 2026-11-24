# Bounded Set epoch function

Own MIT incremental on published main782dad73. No workflows,push or
publication. Public selector and behavior measured with Harbour; no
Harbour implementation copied. Existing SET EPOCH statement shares state.

Set(5) and Set(_SET_EPOCH) read the current epoch; Set(5,n) returns the
previous epoch and stores literal n in0..9999. NIL is a no-op returning
the old value. Initial state1900. Public macro can be undefined/redefined
normally. Source-owned Set keeps normal user dispatch. No generic Set
options/runtime scalar/float setter/error-handler parity is claimed.
Named limits cover selector,range,negative,float,runtime value and extras.

Gate33:3own fixtures exact in5Linux modes,3strict balances0,9profile
rejections,6limits. Includes function-only state linkage,sharing with SET
EPOCH,CToD year boundary and macro replacement. Initial exploratory
invalid-value dialog was not a pass; safe raw measurements are evidence.

Intact upstream tests/dates.prg advances from unknown selector epoch at
line33 to unsupported dateformat selector at line36. Still NOT a closed
example. Census admission remains48/1041. This partial admission is
reported as such,not a speed result or a new passing original.

    python tests/set-epoch/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /unused --output /tmp/set-epoch-check

Final regressions: ASort1..21,timestamp1..9,B1/B2,A1/A2,cycle59,nested51,
inline-date-arithmetic17,Rust104 PASS. Linux1176exact+1inherited ctod,
neg622/13unchanged,PE1912PASS22known0FAIL. Only census rejection text
changes,not admissions. Unsupported Set forms keep the historical
unknown-function diagnostic prefix,so old named negatives remain valid.

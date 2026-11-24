# Literal __SetCentury state function

Own MIT incremental on632d2446489cd54a60c31a38bf292099a2c3cfae.
No workflows,push or publication. Fresh Harbour behavior is specification.

Zero arguments reads the current logical century flag. A logical literal
or case-insensitive exact ON/OFF string sets it and returns the previous
flag. Other literal strings,integer literals and NIL leave it unchanged
and return the previous flag. Whitespace is not trimmed. Runtime values,
floats,extra arguments and effectful arguments remain named limits.
Shares the existing SET CENTURY and DToC renderer state; no Set dateformat
admission yet. Unusual dateformat masks need separate measured semantics.

Gate22:2fixtures5modes exact,2strict balance0,6profile rejections,4limits.
Function-only fixture checks dependency closure; sharing fixture checks
SET CENTURY/SET DATE/DToC state. Added one C getter to our MIT date core;
regenerated assembly via the existing generator. Host gcc needed PIE
addressing to avoid absolute indexed tables; only the known hbc_alloc
PLT call is normalized to a direct local call. External whitelist stays
hbc_alloc. Generated recipe records compiler/flags/source and assembly SHA.

ASort1..21,timestamp1..9,B1/B2,A1/A2,cycle59,nested51,epoch33,inlineDate17,
Rust104 PASS. Linux1176exact+1inherited ctod,neg622/13same,PE1912PASS22known
0FAIL,census48/1041unchanged. Original dates.prg remains blocked by Set
DATEFORMAT,not a closed original. No new speed or non-Linux runtime claim.

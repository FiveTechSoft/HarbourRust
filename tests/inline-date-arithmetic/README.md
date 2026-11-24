# Dominated inline Date arithmetic

Own MIT incremental on5b278dcfe79b26f06b7341aa727f786460e90e98.
No workflows,push or publication. Upstream programs are specifications.

A bare local can reuse the existing Date slot narrowing when its first
mention is a direct unconditional store from an already narrowed Date,
or that Date plus/minus an integer literal. No calls for the offset,
control-flow stores,by-reference targets,prior reads or mixed later
stores are newly admitted. The existing checker still validates every
store and use. No new Date ABI or runtime helper.

The intact upstream tests/dates.prg now reaches unknown Set() at line33,
previously blocked at inline Date arithmetic line21. This is a partial
front-end advance,NOT a closed upstream example or runtime differential.
The census remains48/1041,with one changed rejection diagnostic.

Own gate17:5fresh Harbour exact runs,1strict balance0,3profile rejections,
8named limits for prior reads,control flow,byref,source-before-store,
integer source,prior-loop read,retyped source and effectful offset.
ASort1..21,timestamp1..9,B1/B2,A1/A2,cycle59,nested51 PASS. Rust104.
Linux1176exact+1unchanged inherited ctod failure,neg622/13same,
PE1912PASS22known0FAIL. No new non-Linux support.

    python tests/inline-date-arithmetic/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /unused --output /tmp/date-arithmetic-check

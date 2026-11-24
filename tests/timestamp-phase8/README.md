# Timestamp phase 8: typed Self and scalar DATA

Own MIT on fd1f67c020ba08f68c7b4b3d8fb0985927d8e766. Julio Ponce's MIT e16
and Harbour outputs are specifications only, no implementation/diff copied.
No workflow changes, push or publication are part of this delivery.

Ordinary Linux timestamp programs now allow the known leading Self of a
method call even when another parameter has no fixed type. ValType accepts
Dyn DATA reads from a local object receiver. Existing scalar DATA storage
preserves timestamp tag17. The new boundary does not authorize arbitrary
object values through untyped parameters.

Object lifetime in this profile reuses B1 individual allocation and scalar
DATA-template cleanup. Prior typed-object/Dyn call arguments reuse B2
unwind guards while later arguments evaluate. A failing defaulted-Dyn
object screen releases the typed Self reference too. Owned-string parameters
remain rejected in this profile, since their deferred move needs a separate
unwind protocol. Profiles without classes do not emit object cleanup calls.

This is not B1/B2 dispatch activation, a mixed tracing heap, or container
DATA support. Signature inference can still reject some mixed static calls.
No general ValType of arbitrary method results is added; only checked Dyn
results with a local receiver. Original e16 now reaches its later
lista:={} assignment limit. Its FOR EACH call restriction remains. No whole
e16 pass is claimed. Hash timestamp storage is tested separately, not
assumed from compilation. No PE/Mac runtime extension.

Run from repository root with a new output directory:

    python tests/timestamp-phase8/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --output /tmp/ts8-check

Gate50: six own programs in four Linux modes against fresh Harbour (24 exact
executions), six strict final balances,18 profile rejections,two limits.
Tests cover timestamp DATA, retyping owned text/timestamp/integer DATA,
inheritance, repeated creation/destruction, argument exceptions and hash
read-to-DATA. Final balance requires exact stdout,rc0,empty stderr; missing
DELTA alone never means success. The exploratory Self leak was corrected,
not counted as a pass.

Regressions: timestamp1 42exact+2streams/14balances; phases2..7
61/51/50/49/41/50; B2 115;B1 152;A1/A2;Linux1174;Rust99. PE emission only
1909PASS,22known,0FAIL. Negatives622 identical to phase7,including13known
mismatches. No native PE/Mac claim. Reduced evidence has bundle/patch,
LEEME,compiler SHA,manifest and raw text logs,no binary/object/assembly.

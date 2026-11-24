# Shared nested HB_ISARRAY and HB_ISNUMERIC

Own MIT increment on6a9a0717b0f19918c5a4e6fe9104ecb79cb952fe.
No workflows,push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

HB_ISARRAY/HB_ISNUMERIC accept indexed paths of2..4 levels on already
selected local shared dynamic roots. Existing checked indexed reads return
a borrowed tagged cell; existing predicate tag tests classify it. Numeric
includes both integer tags and heap-float tag5. Strings,logical,NIL,date
and child arrays are not numeric. Only child-array tag16 is an array for
the measured shared payloads. No allocation/clone occurs. Legacy unique
array paths stay unchanged; this neither activates shared identity nor
adds arbitrary call results,module-only roots or other profiles.

Gate18:two own fixtures x5modes=10 exact fresh-Harbour executions,2 zero
final balances,6 other-profile rejections. Covers2/3/4levels,integer,float,
string,logical,NIL,date,child array,aliases,mixed/chained groups,observable
index-effect order and repeated borrowed predicates. No original closes.

61 prior suites PASS including intact arrays/array16 in five Linux modes.
Rust104,Linux1177 stdout goldens exact,PE1912PASS22known0FAIL emission
only. Negative622 combined16 unchanged (Linux7/Windows9). Census56/1041
with no admission/diagnostic changes. No performance claim. ASort2 stays
58=own42+originals16 with mandatory originals.

    python tests/shared-nested-predicates/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-nested-predicates-gate

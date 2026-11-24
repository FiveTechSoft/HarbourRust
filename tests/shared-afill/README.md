# Scalar AFill of an already shared array

Own MIT increment on5bb1f3f4482bfd4445fe4b59528fe9528383ec21.
No workflows,push or publication. Fresh Harbour outputs are specifications
only. No supplied implementation or cambio.diff used. Julio Ponce MIT
attribution remains on unchanged ASort specifications.

AFill of an already-selected local shared array uses its canonical object
length and cell buffer after RHS/start/count evaluation. Existing scalar
fill snapshots a borrowed string/float source before overwriting target
cells,clones payload per cell,releases overwritten string/float values,
and leaves child array objects with the registry. Length/identity stay
unchanged. Existing range clipping/no-op rules and scalar type limits
remain. No new helper,identity activation,array-valued fill or new profile.
Legacy tag8 lowering unchanged.

Gate27:two own fixtures plus intact upstream tests/ains.prg,three sources
x5Linux modes=15 exact fresh-Harbour executions,3 zero final balances,
9 profile rejections. Original alone contributes5exact executions,1zero
balance and3profile rejections. Full original copy/hash/raw outputs are
included. Own fixtures measure source-cell alias snapshots,independent
string payloads,float clones,dropped child alias,zero/negative/outside/
zero-count clipping,empty arrays and repeated string/float/logical fills.

Original ains now closes in all five measured Linux modes,not merely
compile admission. Census57/1041 unchanged because it already compiled
in the preceding partial increment.70prior suites PASS(split35+35),
Rust104,Linux1177stdout exact,PE1912PASS22known0FAIL emission only,
negative622combined16 unchanged(Linux7/Windows9).No performance claim.
ASort2 stays58=42+16 with mandatory original source files.

    python tests/shared-afill/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-afill-gate

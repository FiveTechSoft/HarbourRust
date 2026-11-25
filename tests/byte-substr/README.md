# Rebuilt hb_BSubStr counted-byte slice

Own MIT fresh implementation after environment loss,base main
15607b62f973e68ee4461286101c4be8d970c926. This is NOT recovery of old075d7ed1
or its evidence. Old uncommitted files/raw logs were lost. All evidence in
this package is newly executed25Nov2026 against the rebuilt environment.

Ordinary Linux profile only,no threads/macros. Two or three arguments:
typed string leaf,start integer leaf,optional count integer leaf. Literals
and variables only;constant folding can turn a constant expression into a
leaf. Effectful/computed arguments,Dyn cells,float/count NIL and extra
bounds remain outside scope. Returns independent owned byte copy;source
variables remain borrowed. No code copied from Harbour implementation.

Fresh oracle measurement:positive start is1-based,zero starts at first
byte,negative starts relative to end and clamps at first byte;start beyond
end yields empty. Omitted count takes suffix;negative count is empty;
positive count clips to remaining bytes. NUL and UTF8 are bytes,not Unicode
characters. All256bytes are exercised over517start values. Own assembly
only normalizes offsets/counts then calls the existing counted-byte copier.

Gate47:4positive sources by5modes=20exact Harbour executions,4strict final
zero balances,16profile rejections,7named limits. Matrix of negative/zero/
positive start/count,omitted count,empty,large signed integer bounds,
retained owned input,repeated results and user parameters. Initial negative
fixture used1+1 which constant-folded,changed to variable+1. Initial owned
fixture passed the source to a user function inside the loop and hit the
existing moved-value restriction;that call is after the loop in final.
Failed development runs retained and never counted as pass.

Fresh regression:11relevant prior suites PASS,Rust106,LLVM21fresh exact.
Manifest Linux1181exact stdout/stderr/rc;new harness initially treated all
stderr as empty,then corrected to manifest streams/streams2 semantics and
reran all1181. PE emission1916PASS/22known/0FAIL,no runtime claim.
622negative cases byte-identical diagnostics/status vs fresh base across
Linux/Windows.1041original compile census identical to base,58admitted.
Not a full replay of all prior native suites:external Julio ASort corpus
was lost and remains blocked pending original reforward. No prior PASS
reused. No original closure or speed claim. RC/objects,numeric-array division
remain parked. No push/publication/workflows/rebase.

Candidate compiler8e48d4c73a7997c9fc2310d52efcdc8453b95c6d3eb532311d801082b70cd655.
Fresh Harbour oracle git694428e1c12f726675b19324d62167fa77d68185;
hbmk2SHA2562fb1503a38760b9e94617fd6243ec0a8f65c6a84e079fed0efc47d66633c40ae.
Rust1.100.0. Base binary rebuilt separately with direct release recipe,
SHA2562391469410837657235c212d09f270438553e15030ddfc4ba304a9aef581ac68.
Different source path/build recipe means base binary hash is not the earlier
cargo-built baseline hash. Source base is verified git15607b62.
Julio Ponce MIT programs remain credited independent specifications;
no supplied implementation/cambio.diff used. No old oracle evidence claimed.

python tests/byte-substr/check.py --compiler target/release/hbc --hbmk2 /path/hbmk2 --spec-root /path/harbour --output /new/path

Tests-only current-compiler follow-up onb2620b12 adds variable-length/count
matrix:12source lengths(0,4,..44bytes),97starts(-48..48),51counts(-2..48)
plus omitted count,60528slice observations per execution. Repeated bytes
include ASCII/NUL/UTF8. Separate fixture derives signed minimum i64 at
runtime and tests minimum start/count. Fresh full gate67=30exact runs,
6strict-zero balances,24profile rejections,7named limits. No production
change or global repeat. Current compileraa8cb65c93c5ca8999274fb28dd25e85dff8fcee6aedad394f09751dc52d6986.
Initial matrix used modulo in Chr and hit unrelated numeric type restriction;
replaced with deterministic binary string pattern,failed log retained.

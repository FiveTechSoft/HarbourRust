# ASort after a shared root becomes scalar

Own MIT increment on aa97c8d53fc4bfcf0c79043fe4a2eedef0d2d0dd.
No workflows,push or publication. Harbour sources/outputs are specs only.
No supplied implementation or cambio.diff used. Existing Julio Ponce MIT
attribution on ASort specifications is unchanged.

Fresh Harbour probe confirmed ASort of a selected shared name later
holding string/float returns NIL. Native previously reached its shared
root type error. Shared ASort lowering now checks the root tag after
start/count/extra argument evaluation and returns NIL for nonarrays.
Array roots keep the existing shared sort path and return identity.
No callback ordering algorithm,legacy sort,new activation or other-target
changes. Argument expressions keep their existing evaluation order and
side effects;the nonarray path does not skip them.

Gate9=5 exact fresh-Harbour executions(one own fixture x5Linux modes),
1 strict final balance0,3 profile rejections.117 repeated rounds of
integer/string/float/logical/NIL reassignment and restored array sorting,
plus a STATIC argument trace123 for left-to-right evaluation. No source
adaptation/ErrorBlock. No newly closed original.

83 prior suites PASS(35+48),Rust104,Linux1177stdout goldens exact,
PE1912PASS22known0FAIL emission only,negative622combined16unchanged.
Census57/1041 and diagnostic hashes unchanged. ASort2 stays58=42+16.
Fetched main at12:44:52e08653,including published graph-clone/equality
through77505087. No rebase performed. No publication by this increment.

    python tests/shared-sort-scalar-root/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-sort-scalar-root-gate

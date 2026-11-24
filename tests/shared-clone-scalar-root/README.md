# AClone after a shared local becomes scalar

Own MIT increment on 0cf0a65289a9318c7dd4cef058e10c9654558ac4.
No workflows,push or publication. Harbour sources/outputs are specs only.
No supplied implementation or cambio.diff used. Existing Julio Ponce MIT
attribution on ASort specifications is unchanged.

A selected shared local/parameter is tagged Dyn and can later hold a
scalar. A fresh Harbour probe showed AClone of such string/float values
returns NIL;the compiler previously raised its shared-root type error.
The shared-variable clone lowering now checks the root tag first and
returns NIL without graph traversal for non-arrays. Array roots still
enter the unchanged graph helper. This does not activate shared identity
for ordinary scalar names or admit arbitrary AClone arguments.

Gate9=5 exact fresh-Harbour executions(one own source x5Linux modes),
1 strict final balance0,3 profile rejections. Repeated integer,string,
float,logical,NIL reassignments,direct parameter return and restoration
to nested array cloning cover117rounds. No ErrorBlock/source adaptation.
A date assignment to this selected shared root remains an existing
compile-time rejection and was not counted or admitted. No newly closed
original,legacy-array or other-target change.

82 prior suites PASS(35+47),Rust104,Linux1177stdout goldens exact,
PE1912PASS22known0FAIL emission only,negative622combined16unchanged.
Census57/1041 and diagnostic hashes unchanged. ASort2 stays58=42+16.

    python tests/shared-clone-scalar-root/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-clone-scalar-root-gate

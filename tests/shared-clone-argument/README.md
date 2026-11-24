# AClone values as direct call arguments

Own MIT increment on 05ca8c64741780a41e1b08635ef8b3155d6f5ac3.
No workflows,push or publication. Harbour programs/outputs are specs only.
No supplied implementation or cambio.diff used. Existing Julio Ponce MIT
attribution on ASort specifications remains unchanged.

Discovery propagates shared identity from direct AClone(shared_variable)
or AClone(constant_array_literal) argument values to a direct user-function
parameter. Previously nested access pinned that parameter to a legacy
array type and rejected the dynamic clone argument. A fresh Harbour probe
confirmed isolated mutation for both argument forms. Runtime graph clone,
literal builder and caller argument-root handling are unchanged.
No arbitrary AClone argument expression,indirect call,legacy-array change
or other-target expansion.

Gate18=10 exact fresh-Harbour executions(two own sources x5Linux modes),
2 strict final balances0,6 profile rejections. Nested mutation,independent
arguments,self-cycle,parameter returns and caller argument roots while a
later argument allocates are covered,including37x117 repeated pairs with
owned strings/floats and child graphs. No source adaptation/ErrorBlock.
No newly closed original or performance guarantee.

78 prior suites PASS(35+43),Rust104,Linux1177stdout goldens exact,
PE1912PASS22known0FAIL emission only,negative622combined16unchanged.
Census57/1041 and all diagnostic hashes unchanged. ASort2 retains58=42+16
with mandatory original source files. Only disposable regression ELF
outputs were removed to recover space;logs and prior packages retained.

    python tests/shared-clone-argument/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-clone-argument-gate

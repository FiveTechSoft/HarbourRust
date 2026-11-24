# Direct return of literal AClone

Own MIT increment on 09952e4d2983aa9576e80f8306db31a122e476f2.
No workflows,push or publication. Harbour programs/outputs are specs only.
No supplied implementation or cambio.diff used. Existing Julio Ponce MIT
attribution on ASort specifications remains unchanged.

Discovery now propagates shared-array return identity for the exact
RETURN AClone(constant_array_literal) shape. A fresh unadapted Harbour
probe confirmed independent parent and child identity across invocations
and isolated nested mutation. Previously the native caller lost its shared
name and rejected nested reads. The literal runtime builder is unchanged.
No arbitrary argument/computed literal,legacy-array changes or other
target support. Bare literal RETURN without explicit AClone is not added.

Gate18=10 exact fresh-Harbour executions(two own sources x5Linux modes),
2 strict final balances0,6 profile rejections. Covers independent nested
identity,empty returns,string/float/date/NIL/logical payloads,caller
self-cycle,mutations and 37x117 repeated pairs of returned arrays.
No ErrorBlock or source adaptation. No newly closed original.

77 prior suites PASS(35+42),Rust104,Linux1177stdout goldens exact,
PE1912PASS22known0FAIL emission only,negative622combined16unchanged.
Census57/1041 and diagnostic hashes unchanged. ASort2 stays58=42+16 with
mandatory original sources. One orchestration call timed out after its
commands had completed;all result files and successful logs were checked
before proceeding,no incomplete run is counted.

    python tests/shared-clone-literal-return/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-clone-literal-return-gate

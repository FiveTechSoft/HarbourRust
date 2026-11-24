# Direct return of shared AClone

Own MIT increment on 498e24d5cf635c324add24ba700d7f5ca15d01f6.
No workflows,push or publication. Harbour programs/outputs are specs only.
No supplied implementation or cambio.diff used. Existing Julio Ponce MIT
attribution on ASort specifications remains unchanged.

Discovery now propagates shared-array return identity for the exact
RETURN AClone(shared_variable) shape. Previously assigning that return
to a caller local lost its shared name,so nested reads were rejected even
though a local temporary followed by RETURN worked. The runtime graph
clone itself is unchanged. No arbitrary argument expression,legacy-array
changes or target expansion. An already shared parameter qualifies under
the existing interprocedural names contract. Direct literal-return and
other computed-return shapes are not added by this rule.

Gate18=10 exact fresh-Harbour executions(two own sources x5Linux modes),
2 strict final balances0,6 profile rejections. Parameter direct returns
cover mutual cycles,self-cycle,repeated children,independent invocations,
empty graphs,nested mutation and 37x117 repeated double-clone returns.
No ErrorBlock or source adaptation on this gate. No newly closed original.

76 prior suites PASS(35+41),Rust104,Linux1177stdout goldens exact,
PE1912PASS22known0FAIL emission only,negative622combined16unchanged.
Census57/1041 and diagnostic hashes unchanged. ASort2 stays58=42+16 with
mandatory original source files. No new performance/depth guarantee for
the recursive graph clone and linear invocation-local map.

    python tests/shared-clone-direct-return/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-clone-direct-return-gate

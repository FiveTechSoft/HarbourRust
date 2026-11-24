# Shared array ordering against typed logical operands

Own MIT increment on dd1c617e351807ddc033a64195672ac5ed432507.
No workflows,push or publication. Harbour programs/outputs are specs only.
No supplied implementation or cambio.diff used. Existing Julio Ponce MIT
attribution on ASort specifications is unchanged.

A follow-up audit found typed logical ordering took the old scalar
extraction fallback,not the boxed/Dyn path covered by the earlier array
ordering gate. For example shared_array < .T. recovered Type error: NIL
used as a number instead of Argument error. This increment tests tag16
before extraction on either operand and uses the existing per-operator
array ordering error path. It does not change non-array extraction or
admit a valid ordering between arrays and logicals.

Gate9=5 adapted exact fresh-Harbour executions(one own fixture x5Linux
modes),1 strict final balance0,3 profile rejections. Literal true/false,
typed logical local,both operand directions and all four ordering
operators are repeated37times. Only the oracle installs ErrorBlock/Break
and reads e:Description;the compiler returns its existing caught string.
No Error-object/default-handler equivalence. Uncaught behavior keeps
named diagnostics/exit1 rather than Harbour's dialog. Legacy arrays and
other targets are unchanged. Earlier dynamic-parameter logical coverage
was valid but did not cover this typed fallback.

79 prior suites PASS(35+44),Rust104,Linux1177stdout goldens exact,
PE1912PASS22known0FAIL emission only,negative622combined16unchanged.
Census57/1041 and diagnostic hashes unchanged. No newly closed original.
ASort2 retains58=42+16 with mandatory original sources. Live main fetched
at12:05 was53ed0201 through the float-predicate fix;no rebase performed.

    python tests/shared-array-logical-order/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-array-logical-order-gate

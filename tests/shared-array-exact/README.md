# Shared array exact comparison errors

Own MIT increment on bf9a72d3ef29d087e9beb2065fb560c9f796d9d2.
No workflows,push or publication. Harbour sources and outputs are
specifications only. No supplied implementation or cambio.diff used.
Julio Ponce MIT attribution on existing ASort specifications is unchanged.

The preceding 18-case fresh Harbour probe showed array == non-NIL scalar
raises BASE/1070,while array == array is reference identity and array ==
NIL is false. Static-string native comparisons previously returned false;
other error routes exited without the existing recoverable description.
The tag16 guard now selects the existing exact-comparison error diagnostic
and recoverable Argument error description. Two arrays and NIL still use
the existing exact helper. The static string route frees owned temporary
strings before raising;float-boxing and dynamic routes are covered too.
No change to legacy arrays,ordering,non-array errors or other targets.

Gate18 = 10 adapted exact executions(two own fixtures x5Linux modes),
2 zero strict final balances,6 target-profile rejections. Both operand
orders,integer,float,logical,string/owned-string,shared child cells and
repeated recovery are covered. Existing equality and graph-clone gates
retain array identity and NIL behavior. Only the oracle gets an INIT
ErrorBlock({|err|Break(err)}) and e:Description instead of the compiler's
caught description string. Evidence keeps the adaptation. This is error
condition/description compatibility,not Error-object or default-handler
equivalence. Without recovery the existing diagnostic/exit1 stays,not
Harbour's interactive error dialog.

74 prior suites PASS(35+39),Rust104,Linux1177stdout exact,PE1912PASS22known
0FAIL emission only,negative622combined16unchanged. Census57/1041 and
all diagnostic hashes unchanged. No newly closed original. ASort2 stays
58=42+16 with mandatory original c01/c04 sources.

    python tests/shared-array-exact/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-array-exact-gate

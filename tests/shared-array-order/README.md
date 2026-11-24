# Shared array ordering errors

Own MIT increment on 6b036ebafee719dc392740bc20a22da4994dd796.
No workflows,push or publication. Harbour sources/outputs are specifications
only. No supplied implementation or cambio.diff used. Existing Julio
Ponce MIT attribution on ASort specifications is unchanged.

Fresh 24-case Harbour probe confirms a registered array under <,<=,>,>=
raises BASE/1073,1074,1075,1076 respectively,including self,array,NIL and
scalar right operands. The code now guards tag16 on either operand in
Dyn/Dyn,boxed numeric and static string dispatch. Owned string temporaries
are freed before raising. The helper preserves per-operator existing
uncaught diagnostics and the compiler's recoverable Argument error string.
No successful ordering between arrays is invented.

Gate18=10 adapted exact executions(two own sources x5Linux modes),
2 strict final balances0,6 profile rejections. Both operand directions,
arrays,self,child cells,NIL,integer,float,logical,static and temporary
strings,repeated recovery are exercised. Compiler catches its existing
string;only the oracle installs ErrorBlock/Break and reads e:Description.
This explicit adaptation is retained in raw evidence. Error-object and
default-handler equivalence are NOT claimed. No recovery still exits1
with the existing diagnostic instead of opening Harbour's dialog.
Literal-NIL ordering stays a named compiler rejection;the runtime NIL
case is covered through parameters. No legacy arrays,other targets or
non-array error changes claimed.

75 prior suites PASS(35+40),Rust104,Linux1177stdout goldens exact,
PE1912PASS22known0FAIL emission only,negative622combined16unchanged.
Census57/1041 and all diagnostic hashes unchanged. No newly closed
original. ASort2 stays58=42+16 with mandatory original sources.

    python tests/shared-array-order/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --spec-root /path/to/harbour --output /tmp/shared-array-order-gate

# Dyn division I2

Run `python3 tests/dyn-division/check.py --compiler ./hbc --hbmk2 /path/hbmk2 --wine /path/wine --tree $(git rev-parse HEAD) --output /tmp/division-evidence`.

Outside DBF, Dyn division unpacks integer or heap-float operands by kind and returns F64, with SET DECIMALS=2. DBF arithmetic keeps its existing tagged path. Invalid NIL/string/logical operands raise `Argument error: /` after BOTH operands have evaluated. Zero division keeps the existing zero-division error. An owned temporary is released before dispatching either error; a borrowed local is not consumed. F64 method returns use the same ABI as F64 ordinary calls.

The gate has 30 assertions:

- Four manifest programs run byte-exact against fresh Harbour GTSTD, plus Linux/Wine pinned output. The object oracle prepends hbclass.ch only, preserving the actual object DATA read path.
- One catch matrix freezes the description-string interface. It does not claim Harbour Error-object identity, genCode or subCode support.
- Three invalid-lhs order probes require lhs, rhs, then the argument error, including rhs zero and logical. Invalid kind takes precedence over zero.
- Fifteen per-route/per-N comparisons execute 45 instrumented programs. Routes are borrowed local, Call, Send, SelfGet and memvar; N=1,500,1000; each compares control, float and string. Bound is exactly0 for borrowed/Call/memvar, exactly2 for Send/SelfGet (constant object pool). SelfGet catches inside the same method. Compile failure, abnormal rc, unexpected stderr, missing DELTA or wrong stdout fails closed.
- Three cross-frame comparisons execute six instrumented programs. A method accessing string DATA and failing to a caller's catch retains one block above the pool baseline, also with Break and no division. Both controls are exactly3 at every N. This is a measured existing unwind limitation, NOT a no-leak result.
- Four frontiers are named rejections, not executed ownership coverage: DATA array/object assignment and comma-expression Dyn float/string results. Kind8/13 release branches are defensive and not claimed as covered runtime paths.

Pre-fix evidence is carried separately in the increment package: owned-string N500 leaks, operand order mismatch, and F64 Send compiler panic. The compiler change and every final result are bound to a commit and compiler hash. No Harbour implementation code is included; Harbour is only an external oracle. macOS gates here are emission-only, not native execution.

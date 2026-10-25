// Constant-folded comparisons still evaluate both operands left to
// right: `f() = NIL` (string vs NIL is always .F., probe n1) must call
// f, and a Dyn-side call inside `!= ""` (always .T.) must run too.
function f()
   ? "called"
return "x"
function show(p)
   ? p
   if p = NIL
      ? "nil-in"
   else
      ? "num-in"
   endif
return p
function main()
local a := {}
AAdd(a, 7)
if f() = NIL
   ? "BAD1"
else
   ? "ok1"
endif
if NIL != f()
   ? "ok2"
else
   ? "BAD2"
endif
if show(a[1]) != ""
   ? "ok3"
else
   ? "BAD3"
endif
return nil

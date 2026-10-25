// Comparisons with a constant answer still evaluate both operands left
// to right: `f() = NIL` (string vs NIL is always .F., probe n1) must
// call f, and a Dyn-side call inside `!= ""` must run too. The third
// case uses a NIL casilla: NIL != "" is .T. (hk35). A NUMBER casilla
// against a string instead errors - hk34/hk38 (BASE/1071/1072)
// disproved the old always-.T. fold; t351/t352 cover it.
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
local b := {}
AAdd(b, 1)
ASize(b, 2)
if show(b[2]) != ""
   ? "ok3"
else
   ? "BAD3"
endif
return nil

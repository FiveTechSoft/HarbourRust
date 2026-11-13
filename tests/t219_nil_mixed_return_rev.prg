// Mixed return, reversed order: `return nil` FIRST, the integer return
// after (probe n2 semantics are order-independent). Plus NIL != int.
function g(p)
   if p > 0
      return nil
   endif
return 7
function main()
local r := NIL
r := g(1)
? r
r := g(0)
? r
if g(1) = NIL
   ? "ok1"
else
   ? "BAD1"
endif
if g(0) = 7
   ? "ok2"
else
   ? "BAD2"
endif
if NIL != 0
   ? "ok3"
else
   ? "BAD3"
endif
if NIL != NIL
   ? "BAD4"
else
   ? "ok4"
endif
? g(0) + 2
return nil

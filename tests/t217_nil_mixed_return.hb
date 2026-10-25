// Mixed return (probe n2): one branch returns an integer, the fall-through
// returns NIL; the call result is the tagged union and supports
// comparison, print and arithmetic (tag checked).
function g(p)
   if p > 0
      return 7
   endif
return nil
function main()
local r := NIL
r := g(1)
? r
r := g(0)
? r
if g(0) = NIL
   ? "ok1"
else
   ? "BAD1"
endif
if g(1) = 7
   ? "ok2"
else
   ? "BAD2"
endif
? g(1) + 2
return nil

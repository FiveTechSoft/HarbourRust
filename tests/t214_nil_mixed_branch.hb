// Mixed branch (probe n2): a local widened to the tagged union holds NIL
// or an integer across the if join, compares, and reassigns.
function main()
local x := 5
if x > 3
   x := NIL
else
   x := 7
endif
? x
if x = NIL
   ? "ok1"
else
   ? "BAD1"
endif
x := 9
? x
if x = 9
   ? "ok2"
else
   ? "BAD2"
endif
return nil

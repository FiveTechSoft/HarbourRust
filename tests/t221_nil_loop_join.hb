// Tagged local across a loop join: NIL before the loop, integers inside,
// and the tag survives the loop-exit join (probe n2 assignment rules).
function main()
local y := NIL
local i := 1
? y
while i <= 3
   y := i * 10
   i := i + 1
enddo
? y
if y = 30
   ? "ok1"
else
   ? "BAD1"
endif
y := NIL
while i <= 5
   i := i + 1
enddo
? y
return nil

// ains P2 stage 1: the ONLY Dyn bridge - a Dyn-held array is LENT
// read-only to an array-view parameter (kind 1 header {ptr, len} built
// after a tag-8 guard). The owner survives the call unchanged.
function dump(a)
   local i
   for i := 1 to len(a)
      ?? valtype(a[i])
   next
   ? ""
   return len(a)
procedure main()
local x
x := { 1, "xy", .t., NIL }
? dump(x)
? valtype(x), x[2]
return

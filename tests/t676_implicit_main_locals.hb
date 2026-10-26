// Implicit main: locals declared at the top of the leading group work
// like locals in any body; an optional closing `return` is consumed
// (oracle hk247a).
local x := 40
x += 2
? x
return

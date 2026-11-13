function bump(x)
local old := x++
return old + ++x
function main()
local x := 2
? bump(@x), x
? bump(x), x
return

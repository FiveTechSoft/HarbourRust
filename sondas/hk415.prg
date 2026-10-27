function bump(x)
local old := x++
return old + ++x
function main()
local x := 2
local b := {|| x++, ++x}
? bump(@x), x
? Eval(b), x
? Eval(b), x
return

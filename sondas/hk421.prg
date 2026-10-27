function echo(x)
return +x
function main()
local x := 3
local d := 1.5
? +x, x + +x, x, - -x
? +d, +(d+1), +1.5, +(x++)
? x, +(++x), x
? echo(5), +.T., +NIL, +"abc"
return

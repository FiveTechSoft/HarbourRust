function probe(n)
local a := {7,8,9}
local x := 0
? (x++,a[n+0],x++)
return x
function main()
? probe(4)
return

procedure main()
local x
x := { 1, 2, 3 }
asize(x, 5)
? len(x), x[1], x[4]
asize(x, 2)
? len(x), x[1], x[2]
asize(x, -1)
? len(x)
asize(x, 0)
? len(x)
return

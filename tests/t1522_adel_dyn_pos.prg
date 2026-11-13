procedure main()
local x
x := { 1, 2, 3, 3, 4, 5 }
adel(x, 3)
? len(x), x[1], x[2], x[3], x[4], x[5], x[6]
adel(x, 0)
? x[1], x[6]
adel(x, -1)
? x[1]
adel(x, 7)
? x[1], x[6]
return

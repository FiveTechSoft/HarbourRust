procedure main()
local x
x := { 1, 2, 4 }
ains(x, 3)
? len(x), x[1], x[2], x[3]
x[3] := "3"
ains(x, 0)
? len(x), x[1], x[2], x[3]
ains(x, -1)
? len(x), x[1]
ains(x, 5)
? len(x), x[1]
return

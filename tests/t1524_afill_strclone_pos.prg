procedure main()
local x, y
x := { "a", "b", "c" }
y := "z"
afill(x, y, 2, 2)
? x[1], x[2], x[3]
x[2] := "MUT"
? x[2], x[3]
asize(x, 2)
? len(x), x[1], x[2]
return

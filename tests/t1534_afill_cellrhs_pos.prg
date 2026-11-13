procedure main()
local x, y
x := { "a", "b", "c" }
afill(x, x[1])
? x[1], x[2], x[3]
x := { "a", "b", "c" }
afill(x, x[3], 1, 2)
? x[1], x[2], x[3]
x := { "a", "b", "c" }
afill(x, x[2], 2, 1)
? x[1], x[2], x[3]
x := { "a", "b", "c" }
y := { "z" }
afill(x, y[1], 2, 2)
? x[1], x[2], x[3], y[1]
return

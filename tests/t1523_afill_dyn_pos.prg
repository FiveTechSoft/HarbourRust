procedure main()
local x
x := { 1, 2, 3, 4, 5, 6 }
afill(x, "!")
? x[1], x[3], x[6]
x := { 1, 2, 3, 4, 5, 6 }
afill(x, "X", 3)
? x[2], x[3], x[6]
x := { 1, 2, 3, 4, 5, 6 }
afill(x, 9, 3, 2)
? x[2], x[3], x[4], x[5]
afill(x, .t., 1, 1)
? x[1]
afill(x, NIL, 2, 1)
? x[2]
return

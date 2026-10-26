procedure main()
   ? outer(1.25, 2.5)
   ? outer(10, 0.125)
return

function inner(x)
   return x * 4

function outer(x, y)
   local z := x * 3
   return z + inner(y)

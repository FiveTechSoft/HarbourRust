procedure main()
local x, i
x := { "a", "b", "c", "d" }
for i := 1 to 20
  asize(x, 4)
  ains(x, 2)
  adel(x, 3)
  afill(x, "s" + hb_ntos(i), 2, 2)
  asize(x, 2)
next
? len(x), x[1], x[2]
return

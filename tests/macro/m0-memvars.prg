procedure main()
   local i
   PRIVATE x := 10
   PRIVATE y := .T.
   PRIVATE z := NIL
   PRIVATE w := -7
   PUBLIC g := 3
   ? &("x"), &("x / 2"), &("x % 3"), &("x * 2"), &("x / 4"), &("X + 1")
   ? &("y .AND. .T."), &("z"), &("w % 3"), &("g ^ 2"), &("x / 0 + 1")
   ? &("x = 10 .AND. y"), &("(x + g) * 2"), &("x / 2 * 3")
   x := 20
   ? &("x")
   x++
   x += 5
   ? &("x * 10")
   for i := 1 to 3
      x := x + i
      ? &("x + 0")
   next
   y := .F.
   ? &("y .OR. x > 30")
return

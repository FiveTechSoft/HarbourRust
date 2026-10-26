procedure main()
   local x := 9000000000.0
   local i
   for i := 1 to 40
      x := x * 9000000000.0
   next
   ? x
   ? x - x
   ? x * 0.0
   ? x + 1.0
   ? -x
   ? x = x
   ? x > 1.0
   return

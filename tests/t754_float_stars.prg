procedure main()
   local x := 9000000000.0
   local i := 1
   while i <= 40
      x := x * 9000000000.0
      i := i + 1
   enddo
   ? x
   ? x - x
   ? x * 0.0
   ? x + 1.0
   ? -x
   ? x = x
   ? x > 1.0
   return

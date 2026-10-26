procedure main()
   local x := 9000000000.0
   local i := 1
   local n := 0.0
   while i <= 40
      x := x * 9000000000.0
      i := i + 1
   enddo
   n := x - x
   ? n = n
   ? n <> n
   ? n < 1.0
   ? n <= 1.0
   ? n > 1.0
   ? n >= 1.0
   ? 1.0 < n
   ? 1.0 <= n
   ? 1.0 > n
   ? 1.0 >= n
   ? 1.0 = n
   ? 1.0 <> n
   ? x = x
   ? x <> x
   ? x > 1.0
   ? x < 1.0
   ? x >= x
   ? x <= x
   ? -x < x
   ? -x <= -x
   ? -x = -x
   ? x = -x
   ? x <> -x
   ? 0.0 = -0.0
   ? -0.0 < 0.0
   ? -0.0 = 0
   return

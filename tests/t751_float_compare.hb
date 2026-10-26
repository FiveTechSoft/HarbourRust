procedure main()
   local x := 1.5
   local y := 2.25
   local z := 0.0
   local mz := 0.0 * -1
   local a := 1.5
   local b := 1.5000000000000002
   local big := 9007199254740993
   local f52 := 67108864.0 * 67108864.0
   local f53 := f52 * 2
   ? x = 1.5
   ? x = 1.5000000000000001
   ? x == 1.5
   ? x < y
   ? y > x
   ? x >= 1.5
   ? x <= 1.5
   ? x <> 1.5
   ? x = 1
   ? 1 = x
   ? 0.1 + 0.2 = 0.3
   ? 0.1 + 0.2 > 0.3
   ? 0.1 + 0.2 >= 0.3
   ? z = mz
   ? mz = 0
   ? mz < z
   ? a < b
   ? a = b
   ? big = f53
   ? 1 = 1.0
   ? 2.5 <= 2.5
   return

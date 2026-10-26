procedure main()
   local x := 1.5, y := 2.25, i := 3, big := 9000000000.0
   local z := 0.0, mz, w := 0.00000000000000001
   ? x + i
   ? i + x
   ? x - i
   ? i - x
   ? x * i
   ? i * x
   ? x / i
   ? i / x
   ? i / 2.0
   ? x + 0.25
   ? 0.5 + x
   ? x * 2
   ? 2 * x
   ? big * big
   ? big + big
   mz := z * -1
   ? mz
   ? z / -1
   ? w * w
   ? w * 0.1
   ? x = 1.5
   ? x = 1.5000000000000001
   ? x == 1.5
   ? x < y
   ? y > x
   ? x >= 1.5
   ? x <= 1.5
   ? x # y
   ? x <> 1.5
   ? x = 1
   ? 1 = x
   ? 0.1 + 0.2 = 0.3
   ? i / 0.0
   return

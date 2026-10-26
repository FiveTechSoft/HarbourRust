function main()
   local x := 1.0000000000000001
   local i := 1
   while i <= 450
      x := x * 1.0000000000000001
      i := i + 1
   enddo
   ? x
   return nil

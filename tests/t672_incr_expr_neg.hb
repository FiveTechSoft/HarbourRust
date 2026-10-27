// Positive regression: expression increment/decrement, Harbour hk246.
function main()
   local x := 0
   do while x++ < 3
      ? x
   enddo
   return

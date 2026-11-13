// Positive regression: expression increment/decrement, Harbour hk246.
function main()
   local x := 1
   local y := --x
   ? y
   return

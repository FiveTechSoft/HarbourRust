// neg: prefix ++ inside an expression is named-rejected this increment.
function main()
   local x := 1
   local y := ++x
   ? y
   return

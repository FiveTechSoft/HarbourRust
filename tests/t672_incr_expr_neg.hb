// neg: postfix ++ inside an expression is named-rejected this increment
// (Harbour semantics measured in hk246; statement forms work).
function main()
   local x := 0
   do while x++ < 3
      ? x
   enddo
   return

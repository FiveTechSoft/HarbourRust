procedure main()
   local x := 9000000000.0
   local i := 1
   while i <= 40
      x := x * 9000000000.0
      i := i + 1
   enddo
   ? iden(x)
   ? iden(-x)
return

function iden(v)
   return v

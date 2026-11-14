procedure Main()
   hb_threadStart(@W())
   ? "main-ends"
return
procedure W()
   local i := 0
   do while i < 50000000
      i++
   enddo
return

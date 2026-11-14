procedure Main()
   local th := hb_threadStart(@W())
   ? "timeout", hb_threadWait(th, 0.1)
   hb_threadJoin(th)
   ? "after-join"
return
procedure W()
   local i := 0
   do while i < 300000000
      i++
   enddo
return

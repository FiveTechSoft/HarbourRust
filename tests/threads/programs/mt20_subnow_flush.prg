procedure Main()
   local m := hb_mutexCreate()
   local th, r, v
   hb_mutexNotify(m, "a")
   th := hb_threadStart(@W(), m)
   r := hb_mutexSubscribeNow(m, 2.0, @v)
   ? "subnow", r, v
   hb_threadJoin(th)
return
procedure W(m)
   local i := 0
   do while i < 50000000
      i++
   enddo
   hb_mutexNotify(m, "b")
return

procedure Main()
   local mtx := hb_mutexCreate()
   local th, val
   th := hb_threadStart(@W(), mtx)
   hb_mutexSubscribe(mtx, 10, @val)
   ? "got", val
   hb_threadJoin(th)
return
procedure W(m)
   local i := 0
   do while i < 500000
      i++
   enddo
   hb_mutexNotify(m, "done")
return

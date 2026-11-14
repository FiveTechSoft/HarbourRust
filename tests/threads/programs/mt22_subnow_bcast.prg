procedure Main()
   local m := hb_mutexCreate()
   local th, r, i := 0
   th := hb_threadStart(@W(), m)
   do while i < 20000000
      i++
   enddo
   hb_mutexNotifyAll(m, "bc")
   hb_threadJoin(th, @r)
   ? "worker-ret", r
return
function W(m)
   local v
   local ok := hb_mutexSubscribeNow(m, 2.0, @v)
   ? "worker-got", ok, v
return ok

procedure Main()
   local m := hb_mutexCreate()
   local th, r, i := 0
   hb_mutexLock(m)
   hb_mutexNotify(m, "one")
   th := hb_threadStart(@W(), m)
   do while i < 30000000
      i++
   enddo
   hb_mutexUnlock(m)
   hb_threadJoin(th, @r)
   ? "worker-sub", r
return
function W(m)
   local v
   local ok := hb_mutexSubscribe(m, 2.0, @v)
   ? "worker-val", v
return ok

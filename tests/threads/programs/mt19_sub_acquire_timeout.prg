procedure Main()
   local m := hb_mutexCreate()
   local th, r, v
   hb_mutexLock(m)
   hb_mutexNotify(m, "x")
   th := hb_threadStart(@W(), m)
   hb_threadJoin(th, @r)
   ? "worker-sub-timeout", r
   hb_mutexUnlock(m)
   ? "main-sub-after", hb_mutexSubscribe(m, 0.2, @v), v
return
function W(m)
   local v
return hb_mutexSubscribe(m, 0.3, @v)

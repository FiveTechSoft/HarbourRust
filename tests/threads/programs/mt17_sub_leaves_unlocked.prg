procedure Main()
   local m := hb_mutexCreate()
   local v, th, r
   hb_mutexNotify(m, "one")
   ? "main-sub", hb_mutexSubscribe(m, 0.2, @v), v
   th := hb_threadStart(@W(), m)
   hb_threadJoin(th, @r)
   ? "worker-lock-after", r
return
function W(m)
return hb_mutexLock(m, 0.3)

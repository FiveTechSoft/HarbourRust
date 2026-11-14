procedure Main()
   local m := hb_mutexCreate()
   local th, r
   hb_mutexLock(m)
   th := hb_threadStart(@W(), m)
   hb_threadJoin(th, @r)
   hb_mutexUnlock(m)
   ? "worker-timed-out", r
   ? "main-unlocked"
return
procedure W(m)
return hb_mutexLock(m, 0.1)

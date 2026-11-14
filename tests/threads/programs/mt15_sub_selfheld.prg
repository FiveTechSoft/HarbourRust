procedure Main()
   local m := hb_mutexCreate()
   local v
   hb_mutexLock(m)
   hb_mutexNotify(m, "held")
   ? "sub-while-held", hb_mutexSubscribe(m, 0.2, @v), v
   hb_mutexUnlock(m)
   ? "sub-after-unlock", hb_mutexSubscribe(m, 0.2, @v), v
return

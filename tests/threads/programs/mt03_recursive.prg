procedure Main()
   local m := hb_mutexCreate()
   hb_mutexLock(m)
   ? "first"
   hb_mutexLock(m)
   ? "second-recursive"
   hb_mutexUnlock(m)
   hb_mutexUnlock(m)
   ? "released"
return

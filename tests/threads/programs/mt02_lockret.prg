procedure Main()
   local m := hb_mutexCreate()
   ? "lock-ret", hb_mutexLock(m)
   ? "unlock-ret", hb_mutexUnlock(m)
return

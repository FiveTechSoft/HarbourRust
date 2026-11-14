procedure Main()
   local mtx := hb_mutexCreate()
   local g := hb_mutexCreate()
   local t1, t2, i := 0
   t1 := hb_threadStart(@Sub(), mtx, g)
   t2 := hb_threadStart(@Sub(), mtx, g)
   do while i < 3000000
      i++
   enddo
   hb_mutexNotifyAll(mtx, "all")
   hb_threadJoin(t1)
   hb_threadJoin(t2)
   ? "woken", Woken(0), "timed", Timed(0)
return
procedure Sub(m, g)
   local v
   if hb_mutexSubscribe(m, 0.5, @v)
      hb_mutexLock(g)
      Woken(1)
      hb_mutexUnlock(g)
   else
      hb_mutexLock(g)
      Timed(1)
      hb_mutexUnlock(g)
   endif
return
function Woken(d)
   static w := 0
   w := w + d
return w
function Timed(d)
   static t := 0
   t := t + d
return t

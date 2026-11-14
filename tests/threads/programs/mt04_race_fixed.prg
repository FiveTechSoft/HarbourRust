procedure Main()
   local mtx := hb_mutexCreate()
   local t1, t2
   t1 := hb_threadStart(@Bump(), mtx)
   t2 := hb_threadStart(@Bump(), mtx)
   hb_threadJoin(t1)
   hb_threadJoin(t2)
   ? "with-mutex", Cnt(0)
return
procedure Bump(m)
   local i
   for i := 1 to 100000
      hb_mutexLock(m)
      Cnt(1)
      hb_mutexUnlock(m)
   next
return
function Cnt(d)
   static n := 0
   n := n + d
return n

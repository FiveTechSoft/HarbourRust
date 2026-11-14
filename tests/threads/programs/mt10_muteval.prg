procedure Main()
   local mtx := hb_mutexCreate()
   local t1, t2
   t1 := hb_threadStart(@W(), mtx)
   t2 := hb_threadStart(@W(), mtx)
   hb_threadJoin(t1)
   hb_threadJoin(t2)
   ? "eval", Cnt(0)
return
procedure W(m)
   local i
   for i := 1 to 50000
      hb_mutexEval(m, {|| Cnt(1) })
   next
return
function Cnt(d)
   static n := 0
   n := n + d
return n

procedure Main()
   local once, r
   ? "before", ValType(once)
   r := hb_threadOnce(@once, {|| Cnt(1) })
   ? "once1", r, ValType(once), Cnt(0)
   r := hb_threadOnce(@once, {|| Cnt(10) })
   ? "once2", r, Cnt(0)
return
function Cnt(d)
   static n := 0
   n := n + d
return n

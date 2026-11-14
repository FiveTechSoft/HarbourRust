procedure Main()
   local once, r
   r := hb_threadOnce(@once)
   ? "claim", r, ValType(once)
   r := hb_threadOnce(@once, {|| Cnt(1) })
   ? "later", r, Cnt(0)
return
function Cnt(d)
   static n := 0
   n := n + d
return n

procedure Main()
   local th, r, r2
   th := hb_threadStart(@W())
   do while Probe(0) == 0
   enddo
   r := Once2()
   hb_threadJoin(th, @r2)
   ? "main", r, Probe(0)
   ? "worker", r2
   ? "cnt", Cnt(0)
return
function W()
   local r
   r := Once2()
return r
function Once2()
   static once
   local r
   r := hb_threadOnce(@once, {|| SpinBlock() })
return r
function SpinBlock()
   local i := 0
   Probe(1)
   do while i < 30000000
      i++
   enddo
   Probe(2)
return Cnt(1)
function Probe(d)
   static n := 0
   if d > 0
      n := d
   endif
return n
function Cnt(d)
   static n := 0
   n := n + d
return n

procedure Main()
   local th, r1, r2
   th := hb_threadStart(@W())
   ? "j1", hb_threadJoin(th, @r1)
   ? "r1", r1
   ? "j2", hb_threadJoin(th, @r2)
   ? "r2-type", ValType(r2)
return
function W()
return "once"

procedure Main()
   local th, r1
   th := hb_threadStart(@Sum(), 10, 20, 30)
   hb_threadJoin(th, @r1)
   ? "three", r1
return
function Sum(a, b, c)
return a + b + c

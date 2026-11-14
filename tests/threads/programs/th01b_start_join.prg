procedure Main()
   local th, ret
   th := hb_threadStart(@Worker(), 41)
   hb_threadJoin(th, @ret)
   ? "handle-type", ValType(th)
   ? "joined", ret
return
procedure Worker(x)
   ? "worker says", x + 1
return x * 2

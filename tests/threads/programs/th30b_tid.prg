procedure Main()
   local th, r, mt, ht, mx, dummy
   mt := hb_threadID()
   ? "main-id-type", ValType(mt)
   ? "main-is-main", hb_threadIsMain()
   mx := hb_mutexCreate()
   th := hb_threadStart(@W(), mx)
   ht := hb_threadID(th)
   ? "handle-id-type", ValType(ht)
   ? "handle-ne-main", ht != mt
   hb_mutexNotify(mx, "go")
   hb_threadJoin(th, @r)
   ? "worker-ne-main", r != mt
return
function W(mx)
   local v, t
   hb_mutexSubscribe(mx, 10, @v)
   t := hb_threadID()
   ? "worker-id-type", ValType(t)
   ? "worker-is-main", hb_threadIsMain()
return t

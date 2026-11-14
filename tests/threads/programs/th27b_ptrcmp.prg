procedure Main()
   local me := hb_threadSelf()
   local th := hb_threadStart(@W())
   ? "type-me", ValType(me)
   ? "type-handle", ValType(th)
   ? "me-eq-other", me == th
   ? "me-ne-other", me != th
   ? "self-not-nil", me != NIL
   hb_threadJoin(th)
return
procedure W()
return

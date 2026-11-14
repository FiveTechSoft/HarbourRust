procedure Main()
   local th := hb_threadStart(@W())
   ? "detach-ret", hb_threadDetach(th)
   ? "join-detached", hb_threadJoin(th)
   hb_threadWaitForAll()
   ? "end"
return
procedure W()
return

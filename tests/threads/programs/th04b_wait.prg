procedure Main()
   local th
   th := hb_threadStart(@W())
   ? "wait-ret", hb_threadWait(th)
   ? "wait-again", hb_threadWait(th, 0.5)
return
procedure W()
return

procedure Main()
   local gate := hb_mutexCreate()
   local th
   // Keep W unfinished until after the timed wait,regardless of CPU speed.
   hb_mutexLock(gate)
   th := hb_threadStart(@W(), gate)
   ? "timeout", hb_threadWait(th, 0.1)
   hb_mutexUnlock(gate)
   hb_threadJoin(th)
   ? "after-join"
return
procedure W(gate)
   hb_mutexLock(gate)
   hb_mutexUnlock(gate)
return

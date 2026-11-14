procedure Main()
   local m := hb_mutexCreate()
   local nS, nL, v
   ? "qi-ret", hb_mutexQueueInfo(m, @nS, @nL)
   ? "qi-vals", nS, nL
   hb_mutexNotify(m, "a")
   hb_mutexNotify(m, "b")
   ? "qi-ret2", hb_mutexQueueInfo(m, @nS, @nL)
   ? "qi-vals2", nS, nL
   ? "qi-1arg", hb_mutexQueueInfo(m)
   hb_mutexSubscribe(m, 0.2, @v)
   hb_mutexSubscribe(m, 0.2, @v)
return

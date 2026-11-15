procedure main()
local t, r, m:=hb_mutexCreate()
r:=value(1.250)
t:=hb_threadStart(@worker(),value(2.500))
? hb_threadJoin(t,@r),r
hb_threadJoin(hb_threadStart(@worker(),value(3.750)))
hb_mutexNotify(m,value(4.500))
? hb_mutexSubscribe(m,0,@r),r
hb_mutexNotify(m,value(5.250))
? hb_mutexSubscribe(m,0,@r),r
? hb_mutexQueueInfo(m,@r,@t),r,t
return
function value(x)
return hb_PValue(1)
function worker(x)
? x
return x

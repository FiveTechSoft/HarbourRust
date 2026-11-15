procedure main()
local m:=hb_mutexCreate()
local t1,t2,r,q,n
local tries:=0
local iteration:=0
for iteration:=1 to 4
 t1:=hb_threadStart(@subscriber(),m)
 t2:=hb_threadStart(@subscriber(),m)
 n:=0
 do while tries<10000000
  hb_mutexQueueInfo(m,@n,@q)
  if n=2
   exit
  endif
  tries++
 enddo
 hb_mutexNotifyAll(m,value(2.500))
 ? hb_threadJoin(t1,@r),r
 ? hb_threadJoin(t2,@r),r
next
return
function value(x)
return hb_PValue(1)
function subscriber(m)
local r
hb_mutexSubscribe(m,2,@r)
return r

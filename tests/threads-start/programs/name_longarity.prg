procedure Main()
local th,r,name:="worker"
th:=hb_threadStart(name,1,2,3,4,5,6,7,8,9,10,11,12)
hb_threadJoin(th,@r)
? r
return
function worker(a,b,c,d,e,f,g,h,i,j,k,l)
return a+b+c+d+e+f+g+h+i+j+k+l

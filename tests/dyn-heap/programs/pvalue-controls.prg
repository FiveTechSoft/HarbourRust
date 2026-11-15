procedure main()
? full(1,"x",2.500,.T.,5,6,7,8,9,10,11)
checks()
? hb_memcheck()
return
function full(a,b,c,d,e,f,g,h,i,j,k)
? hb_PValue(1),hb_PValue(3),hb_PValue(11),hb_PValue(12),hb_PValue(0)
return 0
function checks()
local x:=floating(6.250)
local n:=2
indexed(n++,"x",3.140)
changed(@n)
? n
? x
return 0
function indexed(a,b,c)
local n:=2
? a,b,c
? hb_PValue(n++), n
? hb_PValue(n++), n
return 0
function floating(f)
return hb_PValue(1)
procedure changed(x)
x++
? hb_PValue(1)
return

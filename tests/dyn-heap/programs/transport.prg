procedure main()
? work()
? hb_memcheck()
return
function echo(x)
? x
return x
function makefloat(n)
if n==1
return 2.500
endif
return nil
function work()
local x:=makefloat(1)
local y:=echo(x)
local z:=echo(3.140)
? x,y,z, makefloat(0)
x:=6.2500
? x
return 0

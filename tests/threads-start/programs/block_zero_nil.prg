procedure Main()
local th, r
th := hb_threadStart({|| QOut("inside")})
? hb_threadJoin(th,@r), ValType(r)
return

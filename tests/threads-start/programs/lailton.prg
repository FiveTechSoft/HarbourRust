procedure Main()
local th, r
th := hb_threadStart( {|n| test(n)}, 100 )
? hb_threadJoin(th,@r), r
return
function test(n)
? "worker",n
return n+1

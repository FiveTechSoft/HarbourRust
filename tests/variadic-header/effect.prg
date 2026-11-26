static n:=0
procedure main()
 f(tick(),tick(),tick())
 ? n
 return
function tick()
 n++
 return n
function f(...)
 ? hb_PValue(1),hb_PValue(2),hb_PValue(3),PCount()
 return NIL

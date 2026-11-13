function show(x)
return QQOut(x)
function exercise()
   local s := Chr(65)
   ? show(s) == NIL
   ? Len(s), Asc(s)
   ? show(Chr(66)) == NIL
return
function main()
   exercise()
   ? hb_MemCheck()
return

function show(x)
return QQOut(x)
function exercise()
   local s := Chr(65)
   ? show(AllTrim(" ")) == NIL
   ? show(Chr(Asc(Chr(66)))) == NIL
   ? show(AllTrim(s + " ")) == NIL
   ? Asc(s)
return
function main()
   exercise()
   ? hb_MemCheck()
return

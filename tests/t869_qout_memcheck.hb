function make(n)
return Chr(n)
function exercise()
   local s := Chr(65)
   local b := {|n| QOut(Chr(n)), QQOut(AllTrim(" B ")), n+1}
   local r := QOut(make(67), Chr(68)+Chr(69), AllTrim(" F "), s)
   ? r == NIL, Len(s), Asc(s)
   ? Eval(b, 71)
return
function main()
   exercise()
   ? hb_MemCheck()
return

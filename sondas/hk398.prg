function make(n)
return Chr(n)
function main()
   local s := Chr(65)
   local r := QQOut(make(66), AllTrim(" C "), s)
   ? r == NIL, Len(s), Asc(s)
   r := QOut(make(68)+make(69))
   ? r == NIL
return

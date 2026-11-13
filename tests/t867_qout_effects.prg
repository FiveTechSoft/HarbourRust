function ping(n)
   QQOut("P", n)
return n+0
function main()
   local s := Chr(65)
   local b := {|n| QOut("block", n, Chr(66)), QQOut("tail"), n+1}
   local r := QOut(ping(1), ping(2), s, 1.25, NIL)
   ? r == NIL, Len(s)
   ? Eval(b, 4)
   ? QOut("inner"), QQOut("side"), "outer"
   ? ValType(QOut()), ValType(QQOut())
return

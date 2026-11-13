function main()
   local x
   x := QOut("A", 65, .T.)
   ? ValType(x), x == NIL
   x := QQOut("B", "C")
   ? ValType(x), x == NIL
   QOut()
   QQOut()
   ? "done"
return

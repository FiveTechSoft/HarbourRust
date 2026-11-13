function show(x)
   local r := QQOut(x)
return r
function wrap(x)
return QQOut("[", QQOut(x), "]")
function main()
   ? show("A") == NIL
   ? show(65) == NIL
   ? show(NIL) == NIL
   ? show(.T.) == NIL
   ? wrap("B") == NIL
return

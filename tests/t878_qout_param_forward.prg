function through(x)
return QQOut(x)
function forward(x)
return through(x)
function strong(x)
   local r := QOut(x)
return x+0.5
function main()
   ? forward("F") == NIL
   ? forward(7) == NIL
   ? strong(1.25)
return

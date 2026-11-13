// A parameter the body only copies pins from call-site literal
// evidence (multiarg family): x pins I64 from the literal 1.
function take(x)
local y := x
return QQOut(y)
function main()
take(1)
return

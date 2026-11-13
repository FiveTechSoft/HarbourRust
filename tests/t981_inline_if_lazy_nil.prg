function emit(n)
QOut(n)
return NIL
function main()
local t := .T.
local f := .F.
local x := 1
? If(t, 11, 22), If(f, 11, 22)
If(t, QOut(3), QOut(4))
If(f, QOut(5), QOut(6))
IIF(t, QOut("left"), )
IIF(f, QOut("wrong"), )
IIF(f, , QOut("right"))
IIF(t, , QOut("wrong"))
? IIF(t, NIL, NIL), IIF(f, NIL, NIL)
If(t, (x++, 1), (x++, x++, 2))
? x
if (t)
? "block"
endif
if ((x++, .T.))
? x
endif
return

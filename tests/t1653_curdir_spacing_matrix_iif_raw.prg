PROCEDURE Main()
LOCAL a:={"  ","",1}
? "["
? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2])
?? "]"
? "["
? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[1])
?? "]"
? "["
? IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2])
?? "]"
? "["
? IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2])
?? "]"
? "["
? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), "b"
?? "]"
? "["
? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), 1
?? "]"
? "["
? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), .T.
?? "]"
? "["
? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), NIL
?? "]"
? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2])
? "next"
? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[1])
? "next"
? IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2])
? "next"
? "["
?? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2])
?? "]"
? "["
?? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[1])
?? "]"
? "["
?? IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2])
?? "]"
? "["
?? IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2])
?? "]"
? "["
?? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), "b"
?? "]"
? "["
?? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), 1
?? "]"
? "["
?? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), .T.
?? "]"
? "["
?? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), NIL
?? "]"
?? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2])
? "next"
?? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[1])
? "next"
?? IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2])
? "next"
? "["
QOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]))
?? "]"
? "["
QOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[1]))
?? "]"
? "["
QOut(IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]))
?? "]"
? "["
QOut(IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]))
?? "]"
? "["
QOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), "b")
?? "]"
? "["
QOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), 1)
?? "]"
? "["
QOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), .T.)
?? "]"
? "["
QOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), NIL)
?? "]"
QOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]))
? "next"
QOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[1]))
? "next"
QOut(IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]))
? "next"
? "["
QQOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]))
?? "]"
? "["
QQOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[1]))
?? "]"
? "["
QQOut(IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]))
?? "]"
? "["
QQOut(IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]))
?? "]"
? "["
QQOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), "b")
?? "]"
? "["
QQOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), 1)
?? "]"
? "["
QQOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), .T.)
?? "]"
? "["
QQOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]), NIL)
?? "]"
QQOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]))
? "next"
QQOut("a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[1]))
? "next"
QQOut(IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2]))
? "next"
? "a", IIF(.F.,hb_ntos(a[3]),a[1]), IIF(.F.,hb_ntos(a[3]),a[2])
?? IIF(.F.,hb_ntos(a[3]),a[2])
?? IIF(.F.,hb_ntos(a[3]),a[1])
? "end"
RETURN

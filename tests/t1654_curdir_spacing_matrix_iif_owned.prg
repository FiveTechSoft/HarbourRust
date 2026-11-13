PROCEDURE Main()
LOCAL a:={"  ","",1}
? "["
? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2])
?? "]"
? "["
? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",2),a[1])
?? "]"
? "["
? IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2])
?? "]"
? "["
? IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2])
?? "]"
? "["
? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), "b"
?? "]"
? "["
? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), 1
?? "]"
? "["
? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), .T.
?? "]"
? "["
? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), NIL
?? "]"
? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2])
? "next"
? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",2),a[1])
? "next"
? IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2])
? "next"
? "["
?? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2])
?? "]"
? "["
?? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",2),a[1])
?? "]"
? "["
?? IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2])
?? "]"
? "["
?? IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2])
?? "]"
? "["
?? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), "b"
?? "]"
? "["
?? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), 1
?? "]"
? "["
?? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), .T.
?? "]"
? "["
?? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), NIL
?? "]"
?? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2])
? "next"
?? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",2),a[1])
? "next"
?? IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2])
? "next"
? "["
QOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]))
?? "]"
? "["
QOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",2),a[1]))
?? "]"
? "["
QOut(IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]))
?? "]"
? "["
QOut(IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]))
?? "]"
? "["
QOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), "b")
?? "]"
? "["
QOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), 1)
?? "]"
? "["
QOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), .T.)
?? "]"
? "["
QOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), NIL)
?? "]"
QOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]))
? "next"
QOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",2),a[1]))
? "next"
QOut(IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]))
? "next"
? "["
QQOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]))
?? "]"
? "["
QQOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",2),a[1]))
?? "]"
? "["
QQOut(IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]))
?? "]"
? "["
QQOut(IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]))
?? "]"
? "["
QQOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), "b")
?? "]"
? "["
QQOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), 1)
?? "]"
? "["
QQOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), .T.)
?? "]"
? "["
QQOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]), NIL)
?? "]"
QQOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]))
? "next"
QQOut("a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",2),a[1]))
? "next"
QQOut(IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2]))
? "next"
? "a", IIF(.T.,Replicate(" ",2),a[1]), IIF(.T.,Replicate(" ",0),a[2])
?? IIF(.T.,Replicate(" ",0),a[2])
?? IIF(.T.,Replicate(" ",2),a[1])
? "end"
RETURN

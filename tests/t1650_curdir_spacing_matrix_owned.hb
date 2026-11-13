PROCEDURE Main()

? "["
? "a", Replicate(" ",2), Replicate(" ",0)
?? "]"
? "["
? "a", Replicate(" ",2), Replicate(" ",2)
?? "]"
? "["
? Replicate(" ",2), Replicate(" ",0)
?? "]"
? "["
? Replicate(" ",2), Replicate(" ",2), Replicate(" ",0)
?? "]"
? "["
? "a", Replicate(" ",2), Replicate(" ",0), "b"
?? "]"
? "["
? "a", Replicate(" ",2), Replicate(" ",0), 1
?? "]"
? "["
? "a", Replicate(" ",2), Replicate(" ",0), .T.
?? "]"
? "["
? "a", Replicate(" ",2), Replicate(" ",0), NIL
?? "]"
? "a", Replicate(" ",2), Replicate(" ",0)
? "next"
? "a", Replicate(" ",2), Replicate(" ",2)
? "next"
? Replicate(" ",2), Replicate(" ",0)
? "next"
? "["
?? "a", Replicate(" ",2), Replicate(" ",0)
?? "]"
? "["
?? "a", Replicate(" ",2), Replicate(" ",2)
?? "]"
? "["
?? Replicate(" ",2), Replicate(" ",0)
?? "]"
? "["
?? Replicate(" ",2), Replicate(" ",2), Replicate(" ",0)
?? "]"
? "["
?? "a", Replicate(" ",2), Replicate(" ",0), "b"
?? "]"
? "["
?? "a", Replicate(" ",2), Replicate(" ",0), 1
?? "]"
? "["
?? "a", Replicate(" ",2), Replicate(" ",0), .T.
?? "]"
? "["
?? "a", Replicate(" ",2), Replicate(" ",0), NIL
?? "]"
?? "a", Replicate(" ",2), Replicate(" ",0)
? "next"
?? "a", Replicate(" ",2), Replicate(" ",2)
? "next"
?? Replicate(" ",2), Replicate(" ",0)
? "next"
? "["
QOut("a", Replicate(" ",2), Replicate(" ",0))
?? "]"
? "["
QOut("a", Replicate(" ",2), Replicate(" ",2))
?? "]"
? "["
QOut(Replicate(" ",2), Replicate(" ",0))
?? "]"
? "["
QOut(Replicate(" ",2), Replicate(" ",2), Replicate(" ",0))
?? "]"
? "["
QOut("a", Replicate(" ",2), Replicate(" ",0), "b")
?? "]"
? "["
QOut("a", Replicate(" ",2), Replicate(" ",0), 1)
?? "]"
? "["
QOut("a", Replicate(" ",2), Replicate(" ",0), .T.)
?? "]"
? "["
QOut("a", Replicate(" ",2), Replicate(" ",0), NIL)
?? "]"
QOut("a", Replicate(" ",2), Replicate(" ",0))
? "next"
QOut("a", Replicate(" ",2), Replicate(" ",2))
? "next"
QOut(Replicate(" ",2), Replicate(" ",0))
? "next"
? "["
QQOut("a", Replicate(" ",2), Replicate(" ",0))
?? "]"
? "["
QQOut("a", Replicate(" ",2), Replicate(" ",2))
?? "]"
? "["
QQOut(Replicate(" ",2), Replicate(" ",0))
?? "]"
? "["
QQOut(Replicate(" ",2), Replicate(" ",2), Replicate(" ",0))
?? "]"
? "["
QQOut("a", Replicate(" ",2), Replicate(" ",0), "b")
?? "]"
? "["
QQOut("a", Replicate(" ",2), Replicate(" ",0), 1)
?? "]"
? "["
QQOut("a", Replicate(" ",2), Replicate(" ",0), .T.)
?? "]"
? "["
QQOut("a", Replicate(" ",2), Replicate(" ",0), NIL)
?? "]"
QQOut("a", Replicate(" ",2), Replicate(" ",0))
? "next"
QQOut("a", Replicate(" ",2), Replicate(" ",2))
? "next"
QQOut(Replicate(" ",2), Replicate(" ",0))
? "next"
? "a", Replicate(" ",2), Replicate(" ",0)
?? Replicate(" ",0)
?? Replicate(" ",2)
? "end"
RETURN

FUNCTION Main()
LOCAL a:="ab",b:="c",n:=0
? a$("x"+a), (b+a)$("x"+b+a+Chr(0))
? (a+Chr(0))$("x"+a+Chr(0)), ("x"+a)$(b+a)
IF (b+a)$(b+a+"tail")
 n++
ENDIF
? n
? a$("x"+a)
RETURN NIL

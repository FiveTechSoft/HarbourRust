STATIC n, flag
FUNCTION Main()
LOCAL i := 0
? ValType(n), ValType(flag)
FOR i := 1 TO 5
SetN(i)
? n, ReadN(), flag
NEXT
ClearN()
? ValType(n), n, flag
RETURN NIL
FUNCTION SetN(x)
n := x
flag := .T.
RETURN NIL
FUNCTION ReadN()
RETURN n
FUNCTION ClearN()
n := NIL
flag := .F.
RETURN NIL

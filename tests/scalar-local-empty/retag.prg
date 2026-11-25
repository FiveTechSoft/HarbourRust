FUNCTION Main()
LOCAL x,i:=0
FOR i:=1 TO 100
x:=NIL
? Empty(x)
x:=-1
? Empty(x)
x:="x"
? Empty(x)
x:=""
? Empty(x)
NEXT
RETURN NIL

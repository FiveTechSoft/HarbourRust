FUNCTION Main()
LOCAL x,i:=0
FOR i:=1 TO 10
IF i%2==0
x:=""
ELSE
x:="hello"
ENDIF
? Empty(x),x
NEXT
RETURN NIL

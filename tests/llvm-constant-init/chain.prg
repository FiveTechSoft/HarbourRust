FUNCTION Main()
LOCAL a:="ab",b:=a+"c",c:=b+Chr(0),n:=0
? a,b,Len(c),At(a,b),b=="abc"
FOR n:=1 TO 2
 ? a,b
NEXT
RETURN NIL

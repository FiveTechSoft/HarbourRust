FUNCTION Main()
LOCAL n
LOCAL a:="",b:="",c:=""
FOR n:=0 TO 131
 a:=Replicate("A",n)
 b:=Replicate("b",131-n)
 c:=a+b
 ? n,Len(c),c
NEXT
RETURN NIL

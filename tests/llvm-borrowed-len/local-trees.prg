FUNCTION Main()
LOCAL a:="ab",b:="",c:="é中",n:=0
? Len(a+b),Len(b+b),Len(a+Chr(0)),Len(b+c),Len((b+a)+(c+b))
FOR n:=1 TO 2
 ? Len(a+b)+n,Len(a+b)==2
NEXT
RETURN NIL

FUNCTION Main()
LOCAL a:="M",b:=a+"ain",n:=0
? b,One(),Two(),b
FOR n:=1 TO 2
 ? One(),Two(),Len(b)
NEXT
RETURN NIL
FUNCTION One()
LOCAL a:="ab",b:=a+"c",c:=b+Chr(0)
? a,b,c
RETURN Len(c)+At(a,b)
FUNCTION Two()
LOCAL a:=7,b:=a+3,c:={1,2,3}
? a,b,c[2]
RETURN a+b+Len(c)

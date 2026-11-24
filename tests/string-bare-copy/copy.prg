FUNCTION Main()
 LOCAL s:="abc",a,b,i
 a:=s
 FOR i:=1 TO 3
 a+=a
 NEXT
 b:=a
 FOR i:=1 TO 2
 b+=b
 NEXT
 ? s,a,b
RETURN NIL

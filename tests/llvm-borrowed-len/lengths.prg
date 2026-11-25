FUNCTION Main()
LOCAL a:="hello",b:="",c:="A"+Chr(0)+"B",n:=2
? Len(a),Len(b),Len(c),Len("literal"),Len("a"+"b"),Len(Chr(0))
FOR n:=1 TO 3
 ? n+Len(a),Len(c)*n
NEXT
RETURN NIL

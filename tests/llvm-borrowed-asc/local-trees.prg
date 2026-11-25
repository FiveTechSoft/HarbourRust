FUNCTION Main()
LOCAL a:="A",b:="",c:="é",n:=0
? Asc(a+"x"),Asc(b+a),Asc(b+b),Asc(Chr(0)+a),Asc(b+c)
? Asc(b+Chr(127)),Asc(b+Chr(1)),Asc((b+b)+a)
FOR n:=1 TO 2
 ? Asc(b+a)+n,Asc(b+a)==65
NEXT
RETURN NIL

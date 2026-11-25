FUNCTION Main()
LOCAL a:="",b:=a+Chr(0),c:="é"+a,d:=b+c,n:=0
? Len(a),Len(b),Len(c),Len(d),Asc(b),At(c,d),d==(Chr(0)+"é")
? b,c,d,Empty(a+" "),IsAlpha(a+"A"),d$("x"+d)
FOR n:=1 TO 2
 ? Len(d)+n,d==b+c
NEXT
RETURN NIL

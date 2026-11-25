FUNCTION Main()
LOCAL a:="",b:=a+Chr(0),n:=0
? a==NIL,NIL==a,b=NIL,NIL=b,b!=NIL,NIL!=b
IF (b!=NIL).AND.!(a==NIL)
 n++
ENDIF
? n,IIf(NIL==a,17,99),Empty(a==NIL)
FOR n:=1 TO 2
 ? (a+"x")!=NIL,NIL==(a+"x")
NEXT
RETURN NIL

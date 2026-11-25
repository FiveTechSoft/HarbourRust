FUNCTION Main()
LOCAL a:="ab",b:=a+"c"
? a==NIL,NIL==a,a=NIL,NIL=a,a!=NIL,NIL!=a
? b==NIL,NIL==(a+"x"),(a+"x")!=NIL
RETURN NIL

FUNCTION Main()
LOCAL n:=0,m:=1,b:=.F.
? (n:=7),n,(m:=n+2),m
? (n:=(m:=11)+1),n,m
? (b:=.T.),b
IF (b:=.F.)
 ? "wrong"
ELSE
 ? "false",b
ENDIF
RETURN NIL

FUNCTION Main()
LOCAL n:=0,m:=0
? (n:=1)+(n:=2),n
? (n:=3)*(n:=4),n
? (n:=5)-(n:=2),n
? (n:=(n:=7)+1),n
? ((n:=1),(n:=2),(m:=n+3)),n,m
RETURN NIL

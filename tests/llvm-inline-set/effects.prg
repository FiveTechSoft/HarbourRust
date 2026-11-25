FUNCTION mark(n)
? n
RETURN n+0
FUNCTION Main()
LOCAL n:=0,m:=0,b:=.F.
? (n:=mark(7)),n
? ((m:=m+1),(n:=m+10)),n,m
? IIf(.T.,(n:=3),(n:=99)),n
? .F. .AND. ((n:=88)>0),n
? .T. .OR. ((n:=77)>0),n
(n:=8)
? n
RETURN NIL

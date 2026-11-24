FUNCTION Main()
 LOCAL a:={{"old",NIL}},b
 a[1,1]:=Replicate("word",31)
 b:=a
 b[1,2]:="new"
 a:={{"replacement"}}
 ? b[1,1],b[1,2],a[1,1]
RETURN NIL

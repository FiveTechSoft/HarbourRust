FUNCTION Main()
 LOCAL b:={{{{1,2}}}}
 LOCAL a:={{{"old",NIL}}}
 a[1,1][1]:="one"
 a[1][1,2]:="two"
 ? a[1,1][1],a[1][1,2],a[1,1,1],a[1][1][2]
 b[1,1][1,2]:=19
 ? b[1][1,1][2],b[1,1,1,2]
RETURN NIL

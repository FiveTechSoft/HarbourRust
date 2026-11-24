FUNCTION Idx(n)
 ?? "I",n
RETURN n
FUNCTION Value()
 ?? "V"
RETURN Replicate("word",7)
FUNCTION Main()
 LOCAL a:={{{{"old",NIL}}}},b
 a[Idx(1),Idx(1)][Idx(1),Idx(2)]:=Value()
 ? a[1][1,1][2]
 b:=a
 b[1,1][1,1]:="alias"
 ? a[1,1][1,1],b[1][1][1,2]
 ? "[a,b][c,d]",a[1,1][1,1]
RETURN NIL

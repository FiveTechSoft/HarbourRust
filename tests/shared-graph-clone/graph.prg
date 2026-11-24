FUNCTION Main()
 LOCAL a:={},b,c:=AClone({17}),d
 AAdd(a,c)
 AAdd(a,c)
 b:=AClone(a)
 ? a==b,a[1]==a[2],b[1]==b[2],a[1]==b[1]
 b[1,1]:=23
 ? a[1,1],b[1,1],b[2,1]
 d:={}
 AAdd(d,d)
 b:=AClone(d)
 ? b==d,b[1]==b,b[1]==d
 d:=AClone({"word",19.25,SToD("20040229"),{NIL,.T.}})
 b:=AClone(d)
 b[1]:="changed"
 b[2]:=21.5
 b[4,2]:=.F.
 ? d[1],b[1],d[2],b[2],DToS(b[3]),d[4,2],b[4,2]
RETURN NIL

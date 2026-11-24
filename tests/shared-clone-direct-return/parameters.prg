// Own MIT: graph identity across parameter and return boundaries.
FUNCTION CopyGraph(p)
RETURN AClone(p)
FUNCTION Main()
 LOCAL a:=AClone({"root",{17}}),b,c:=AClone({"child"}),d,e,f
 AAdd(a,c)
 AAdd(a,c)
 AAdd(c,a)
 b:=CopyGraph(a)
 ? a==b,b[3]==b[4],b[3,2]==b,b[3,2]==a
 b[2,1]:=23
 b[3,1]:="changed"
 ? a[2,1],b[2,1],a[3,1],b[4,1]
 d:=CopyGraph(a)
 ? b==d,b[3]==d[3],d[3,2]==d
 b:=CopyGraph(b)
 ? b[3]==b[4],b[3,2]==b,b[3,1]
 e:=AClone({})
 f:=CopyGraph(e)
 ? Len(e),Len(f),e==f
 AAdd(e,e)
 f:=CopyGraph(e)
 ? Len(f),f[1]==f,f[1]==e
RETURN NIL

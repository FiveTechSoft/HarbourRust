// Own MIT: clone array cells at depths two through four.
STATIC n:=0
FUNCTION Ix(i)
 n:=n*10+i
RETURN i
FUNCTION CopyChild(p)
RETURN AClone(p[1,1,1])
FUNCTION Touch(p)
 p[1]:="changed"
RETURN Len(p)
FUNCTION Main()
 LOCAL a:=AClone({{{{"word",19.25,{17}}}}}),b,c,d
 b:=AClone(a[1,1])
 c:=AClone(a[1,1,1])
 d:=AClone(a[1,1,1,3])
 ? b==a[1,1],c==a[1,1,1],d==a[1,1,1,3]
 c[3,1]:=23
 ? c[3,1],d[1],a[1,1,1,1]
 c:=AClone(a[Ix(1),Ix(1),Ix(1)])
 ? n,Touch(AClone(a[1,1,1])),c[1]
 d:=CopyChild(a)
 ? d[1],d[2]
 a[1,1,1,3]:=a[1,1,1]
 d:=AClone(a[1,1,1])
 ? d[3]==d,d==a[1,1,1]
 d:=AClone(a[1,1,1,1])
 ? ValType(d)
RETURN NIL

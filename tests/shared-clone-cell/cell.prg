// Own MIT: clone a borrowed one-level child graph.
FUNCTION CopyChild(p)
RETURN AClone(p[1])
FUNCTION Touch(p)
 p[3,1]:=29
RETURN Len(p)
FUNCTION Main()
 LOCAL a:=AClone({{"word",19.25,{17}}}),b,c
 b:=AClone(a[1])
 ? a[1]==b,a[1,3]==b[3]
 b[3,1]:=23
 ? a[1,3,1],b[3,1]
 c:=CopyChild(a)
 ? c==a[1],c[3,1],Touch(AClone(a[1])),a[1,3,1]
 a[1,3]:=a[1]
 b:=AClone(a[1])
 ? b[3]==b,b[3]==a[1]
 a[1]:="scalar"
 b:=AClone(a[1])
 ? ValType(b)
 a[1]:=19.25
 b:=AClone(a[1])
 ? ValType(b)
 a[1]:=NIL
 b:=AClone(a[1])
 ? ValType(b)
RETURN NIL

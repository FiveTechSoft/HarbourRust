// Own MIT: a selected shared name may hold a scalar on a later path.
FUNCTION CopyGraph(p)
RETURN AClone(p)
FUNCTION Work()
 LOCAL a:=AClone({17}),b,i,n:=0
 FOR i:=1 TO 117
  a:=17
  b:=AClone(a)
  ? ValType(b)
  a:="word"
  b:=AClone(a)
  ? ValType(b)
  a:=19.25
  b:=AClone(a)
  ? ValType(b)
  a:=.T.
  b:=AClone(a)
  ? ValType(b)
  a:=NIL
  b:=AClone(a)
  ? ValType(b)
  b:=CopyGraph(a)
  ? ValType(b)
  a:=AClone({"again",{17}})
  b:=AClone(a)
  b[2,1]:=23
  n+=Len(b)
 NEXT
 ? n,a[2,1],b[2,1]
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL

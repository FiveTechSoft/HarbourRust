// Own MIT: scalar fallback and one evaluation of an effectful index.
STATIC n:=0
FUNCTION Ix(i)
 n:=n*10+i
RETURN i
FUNCTION Main()
 LOCAL a:=AClone({17,.T.,SToD("20040229"),"word",19.25,NIL,{"child"}}),b,i,total:=0
 FOR i:=1 TO 6
  b:=AClone(a[i])
  ? ValType(b)
 NEXT
 b:=AClone(a[Ix(7)])
 ? n,b==a[7],b[1]
 b[1]:="changed"
 ? a[7,1],b[1]
 FOR i:=1 TO 117
  b:=AClone(a[1])
  b:=AClone(a[2])
  b:=AClone(a[3])
  b:=AClone(a[4])
  b:=AClone(a[5])
  b:=AClone(a[6])
  total+=Len(a)
 NEXT
 ? total,ValType(b)
RETURN NIL

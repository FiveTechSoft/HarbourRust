// Own MIT: non-array shared roots still evaluate arguments left-to-right.
STATIC trace:=0
FUNCTION Arg(n)
 trace:=trace*10+n
RETURN n
FUNCTION Work()
 LOCAL a:=AClone({3,1,2}),b,i
 FOR i:=1 TO 117
  a:=17
  b:=ASort(a,Arg(1),Arg(2),Arg(3))
  ? ValType(b)
  a:="word"
  b:=ASort(a)
  ? ValType(b)
  a:=19.25
  b:=ASort(a)
  ? ValType(b)
  a:=.T.
  b:=ASort(a)
  ? ValType(b)
  a:=NIL
  b:=ASort(a)
  ? ValType(b)
  a:=AClone({3,1,2})
  b:=ASort(a)
  ? b==a,a[1],a[2],a[3]
  trace:=0
 NEXT
 a:="word"
 b:=ASort(a,Arg(1),Arg(2),Arg(3))
 ? ValType(b),trace
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL

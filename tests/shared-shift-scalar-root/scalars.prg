// Own MIT: statement-only shifts preserve scalar root and index effects.
STATIC n:=0
FUNCTION Index()
 n+=1
RETURN 1
FUNCTION Work()
 LOCAL a:=AClone({3,1,2}),i
 FOR i:=1 TO 117
  a:=17
  AIns(a,Index())
  ADel(a,Index())
  ? a
  a:="word"
  AIns(a,Index())
  ADel(a,Index())
  ? a
  a:=19.25
  AIns(a,Index())
  ADel(a,Index())
  ? a
  a:=.T.
  AIns(a,Index())
  ADel(a,Index())
  ? a
  a:=NIL
  AIns(a,Index())
  ADel(a,Index())
  ? ValType(a)
  a:=AClone({3,"word",19.25})
  AIns(a,2)
  ADel(a,1)
  ? ValType(a[1]),a[2],ValType(a[3])
 NEXT
 ? n
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL

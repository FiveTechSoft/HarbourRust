// Own MIT: selected shared variable later holds a non-array.
FUNCTION Work()
 LOCAL a:=AClone({3,1,2}),b,i
 FOR i:=1 TO 117
  a:=17
  b:=ATail(a)
  ? ValType(b)
  a:="word"
  b:=ATail(a)
  ? ValType(b)
  a:=19.25
  b:=ATail(a)
  ? ValType(b)
  a:=.T.
  b:=ATail(a)
  ? ValType(b)
  a:=NIL
  b:=ATail(a)
  ? ValType(b)
  a:=AClone({3,1,"last"})
  b:=ATail(a)
  a[3]:="changed"
  ? b,a[3]
  a:=AClone({{9}})
  b:=ATail(a)
  b[1]:=7
  ? a[1,1],b==a[1]
 NEXT
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL

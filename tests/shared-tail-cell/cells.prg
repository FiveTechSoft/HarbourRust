// Own MIT: borrowed indexed source and owned final payload.
STATIC n:=0
FUNCTION Index()
 n+=1
RETURN 1
FUNCTION Work()
 LOCAL a:=AClone({{"last"},{},{17},{19.25},{.T.},{NIL},{{9}},17,"scalar",NIL}),b,i
 FOR i:=1 TO 117
  b:=ATail(a[Index()])
  a[1,1]:="changed"
  ? b,a[1,1]
  a[1,1]:="last"
  b:=ATail(a[2])
  ? ValType(b)
  b:=ATail(a[3])
  ? b
  b:=ATail(a[4])
  ? b
  b:=ATail(a[5])
  ? b
  b:=ATail(a[6])
  ? ValType(b)
  b:=ATail(a[7])
  b[1]:=7
  ? a[7,1,1],b==a[7,1]
  b:=ATail(a[8])
  ? ValType(b)
  b:=ATail(a[9])
  ? ValType(b)
  b:=ATail(a[10])
  ? ValType(b)
 NEXT
 ? n
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL

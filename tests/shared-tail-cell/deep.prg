// Own MIT: deeper final cells reuse the same bounded borrowed reader.
FUNCTION Work()
 LOCAL a:=AClone({{{{{"last"}}}}}),b,i
 FOR i:=1 TO 117
  b:=ATail(a[1,1])
  ? b==a[1,1,1]
  b:=ATail(a[1,1,1])
  ? b==a[1,1,1,1]
  b:=ATail(a[1,1,1,1])
  ? b
 NEXT
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL

FUNCTION Main()
 LOCAL a:={{NIL}},b:=Array(10000),c
 a[1,1]:=1
 ? Len(b),ValType(b),ValType(b[10000]),ValType(b[1])
 b[10000]:="Harbour"
 c:=b
 c[1]:=17
 ? b[1],b[10000],c[10000]
 ASize(b,2)
 ? Len(c),b[1],b[2]
 AAdd(c,19.25)
 ? Len(b),b[3]
RETURN NIL

FUNCTION Main()
 LOCAL a:={7,3,9,1},b
 b:=a
 ? ASort(a)==a,a[1],b[4]
 b[1]:=42
 ? a[1],Len(a)
RETURN NIL

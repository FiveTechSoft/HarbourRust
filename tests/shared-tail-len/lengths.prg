FUNCTION Main()
 LOCAL a:={{NIL}},b:={}
 a[1,1]:=1
 AAdd(b,"")
 ? Len(ATail(b))
 b[1]:="Harbour"
 ? Len(ATail(b)),b[1]
 AAdd(b,{"a","b"})
 ? Len(ATail(b)),Len(b)
 AAdd(b,{})
 ? Len(ATail(b)),Len(b)
RETURN NIL

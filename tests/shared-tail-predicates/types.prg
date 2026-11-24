FUNCTION Show(a)
 ? HB_ISARRAY(ATail(a)),HB_ISNUMERIC(ATail(a)),HB_ISSTRING(ATail(a))
RETURN NIL
FUNCTION Main()
 LOCAL a:={{NIL}},b:={}
 a[1,1]:=1
 Show(b)
 AAdd(b,17)
 Show(b)
 AAdd(b,"word")
 Show(b)
 AAdd(b,19.25)
 Show(b)
 AAdd(b,.T.)
 Show(b)
 AAdd(b,SToD("20040229"))
 Show(b)
 AAdd(b,{"nested"})
 Show(b)
 ? b[6,1],Len(b)
RETURN NIL

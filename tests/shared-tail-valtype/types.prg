FUNCTION Main()
 LOCAL a:={{NIL}},b:={}
 a[1,1]:=1
 ? ValType(ATail(b))
 AAdd(b,17)
 ? ValType(ATail(b))
 AAdd(b,"word")
 ? ValType(ATail(b))
 AAdd(b,19.25)
 ? ValType(ATail(b))
 AAdd(b,.T.)
 ? ValType(ATail(b))
 AAdd(b,SToD("20040229"))
 ? ValType(ATail(b))
 AAdd(b,{"nested"})
 ? ValType(ATail(b)),b[6,1],Len(b)
RETURN NIL

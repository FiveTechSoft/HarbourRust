FUNCTION Make()
 LOCAL a:={}
 AAdd(a,hb_SToT("20261123101530987"))
 AAdd(a,"tail")
RETURN a
FUNCTION Extend(a)
 AAdd(a,hb_DToT(SToD("20260102")))
RETURN Len(a)
FUNCTION Main()
 LOCAL a:=Make(),b:=a
 ? Extend(b),Len(a),ValType(a[1]),hb_TToC(b[1]),a[2],hb_TToS(a[3])
 a:={}
 ? Len(a),Len(b),hb_TToS(b[1])
RETURN NIL

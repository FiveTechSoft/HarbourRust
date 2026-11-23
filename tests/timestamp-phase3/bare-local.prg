FUNCTION Main()
 LOCAL a,i,t
 FOR i:=1 TO 101
  a:={}
  t:=hb_SToT("20261123101530987")
  AAdd(a,t)
  AAdd(a,"x"+Str(i,3))
  AAdd(a,1.25)
  AAdd(a,SToD("20261123"))
 NEXT
 ? Len(a),hb_TToS(a[1]),a[2],ValType(a[3]),ValType(a[4])
RETURN NIL

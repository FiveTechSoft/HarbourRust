FUNCTION Make()
 LOCAL a:={},b:={}
 AAdd(a,hb_SToT("20261123101530987"))
 AAdd(a,b)
 AAdd(b,a)
RETURN b
FUNCTION Main()
 LOCAL b:=Make(),a:=b[1],i,junk:={}
 FOR i:=1 TO 517
  junk:={}
  AAdd(junk,"discard")
 NEXT
 ? Len(a),Len(b),hb_TToS(a[1])
 b:={}
 a:={}
RETURN NIL

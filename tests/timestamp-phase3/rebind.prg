FUNCTION Main()
 LOCAL a:={},b,i
 AAdd(a,hb_SToT("20261123101530987"))
 b:=a
 FOR i:=1 TO 101
  a:={}
  AAdd(a,SToD("20260102"))
  AAdd(a,"x")
 NEXT
 ? hb_TToS(b[1]),hb_TToS(a[1]),a[2]
 ASize(b,0)
 ? Len(b),Len(a)
RETURN NIL

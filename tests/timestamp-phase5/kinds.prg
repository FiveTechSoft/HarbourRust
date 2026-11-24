FUNCTION Main()
 LOCAL a:={},i,c:="",t:=hb_SToT("20261123")
 AAdd(a,0.0)
 AAdd(a,-0.0)
 AAdd(a,1.25)
 AAdd(a,SToD(""))
 AAdd(a,SToD("20261123"))
 AAdd(a,hb_SToT(""))
 AAdd(a,t)
 FOR i:=1 TO Len(a)
  ? Empty(a[i])
 NEXT
RETURN NIL

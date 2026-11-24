FUNCTION Same(a,b)
RETURN a==b
FUNCTION Main()
 LOCAL a:={},i,t:=hb_SToT("20261123101530"),n:=0
 AAdd(a,t)
 AAdd(a,hb_SToT("20261123101531"))
 AAdd(a,"text")
 FOR i:=1 TO 101
  IF a[1]<a[2]
   n++
  ENDIF
 NEXT
 ? n,Same(a[1],t),Same(a[1],a[2]),a[1]<=a[1],a[2]>=a[1],a[3]
RETURN NIL

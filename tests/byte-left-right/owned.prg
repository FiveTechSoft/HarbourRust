PROCEDURE Main()
 LOCAL s:=Upper("abc"),n:=2,t:="",i:=0
 FOR i:=1 TO 101
 t:=hb_BLeft(s,n)
 ? t,hb_BRight(s,n),s,n
 NEXT
 ? Probe(s,n)
RETURN
FUNCTION Probe(s,n)
RETURN hb_BLeft(s,n)+hb_BRight(s,n)

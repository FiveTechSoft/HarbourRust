PROCEDURE Main()
 LOCAL s:=Upper("abcdef"),n:=2,k:=3,t:="",i:=0
 FOR i:=1 TO 101
 t:=hb_BSubStr(s,n,k)
 ? t,s,hb_BSubStr(s,n)
 NEXT
 ? Probe(s,n,k)
RETURN
FUNCTION Probe(s,n,k)
RETURN hb_BSubStr(s,n,k)+hb_BSubStr(s,n)

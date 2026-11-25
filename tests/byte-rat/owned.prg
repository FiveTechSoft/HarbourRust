PROCEDURE Main()
 LOCAL s:=Upper("xabcyabc"),n:=Lower("ABC"),i:=0
 FOR i:=1 TO 101
 ? hb_BRAt(n,s),s,n
 NEXT
 ? Probe(n,s)
RETURN
FUNCTION Probe(n,s)
RETURN hb_BRAt(n,s)

PROCEDURE Main()
 ? Probe(2),Probe(-2)
RETURN
FUNCTION Probe(s)
 LOCAL i:=0,n:=0
 FOR i:=1 TO 5 STEP s
 n+=i
 NEXT
RETURN n

PROCEDURE Main()
 LOCAL i:=0
 FOR i:=1 TO 71
  ? Probe("abc"),Probe("def"),Probe(""),Probe(NIL)
 NEXT
RETURN
FUNCTION Probe(s)
 IF !(s==NIL) .AND. !(Upper(s)=="DEF")
  RETURN Upper(s)
 ENDIF
RETURN "none"

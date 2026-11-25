PROCEDURE Main()
 LOCAL s:=Lower("DIR/ABC.OLD"),e:=Lower("TXT"),t:="",i:=0
 FOR i:=1 TO 101
 t:=hb_FNameExtSet(s,e)
 ? t,s,e,hb_FNameExtSet(s,s),hb_FNameExtSet(e,e)
 NEXT
 ? s,e,Probe(s,e)
RETURN
FUNCTION Probe(s,e)
RETURN hb_FNameExtSet(s,e)

PROCEDURE Main()
 LOCAL h:={"a"=>1},v:=NIL
 FOR EACH v IN h
  IF .T. .AND. hb_HSetDef(h,"b",2)==2
   ? v:__enumKey()
  ENDIF
 NEXT
RETURN

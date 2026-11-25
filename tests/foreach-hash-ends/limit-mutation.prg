PROCEDURE Main()
 LOCAL h:={"a"=>1},v:=NIL
 FOR EACH v IN h
 hb_HClear(h)
 ? v:__enumIsFirst()
 NEXT
RETURN

PROCEDURE Main()
 LOCAL h:={"a"=>1},q:={"b"=>2},v:=NIL
 FOR EACH v IN h
  hb_HCopy(q,h)
  ? v:__enumKey()
 NEXT
RETURN

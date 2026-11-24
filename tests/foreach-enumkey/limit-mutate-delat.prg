PROCEDURE Main()
 LOCAL h:={"a"=>1},q:={"b"=>2},v:=NIL
 FOR EACH v IN h
  hb_HDelAt(h,1)
  ? v:__enumKey()
 NEXT
RETURN

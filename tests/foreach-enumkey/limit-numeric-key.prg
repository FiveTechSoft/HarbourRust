PROCEDURE Main()
 LOCAL h:={"a"=>1},v:=NIL
 h[1]:=2
 FOR EACH v IN h
  ? v:__enumKey()
 NEXT
RETURN

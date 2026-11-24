PROCEDURE Main()
 LOCAL h:={"first"=>1,"second"=>2},q:={"x"=>3,"y"=>4},v:=NIL,w:=NIL
 FOR EACH v IN h
  FOR EACH w IN q
   ? v:__enumKey(),w:__enumKey
   IF w==3
    LOOP
   ENDIF
   EXIT
  NEXT
 NEXT
RETURN

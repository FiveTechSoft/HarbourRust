PROCEDURE Main()
 LOCAL h:={"a"=>1,"b"=>2},q:={"x"=>3,"y"=>4},v:=NIL,w:=NIL
 FOR EACH v IN h
  FOR EACH w IN q
   ? v:__enumIsFirst,w:__enumIsFirst(),v:__enumIsLast,w:__enumIsLast()
   IF w:__enumIsFirst
    LOOP
   ENDIF
   EXIT
  NEXT
 NEXT
RETURN

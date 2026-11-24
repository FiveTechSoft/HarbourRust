PROCEDURE Main()
 LOCAL h:={=>},q:={"only"=>NIL},v:=NIL
 FOR EACH v IN h
  ? "unexpected",v:__enumIsFirst(),v:__enumIsLast()
 NEXT
 FOR EACH v IN q
  ? v:__enumIsFirst(),v:__enumIsLast()
 NEXT
RETURN

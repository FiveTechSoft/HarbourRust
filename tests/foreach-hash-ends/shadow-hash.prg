PROCEDURE Main()
 LOCAL h:={"a"=>1,"b"=>2},q:={"only"=>3},v:=NIL
 FOR EACH v IN h
  ? "before",v:__enumIsFirst(),v:__enumIsLast()
  FOR EACH v IN q
   ? "inner",v:__enumIsFirst(),v:__enumIsLast()
  NEXT
  ? "after",v:__enumIsFirst(),v:__enumIsLast()
 NEXT
RETURN

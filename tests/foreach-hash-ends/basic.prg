PROCEDURE Main()
 LOCAL h:={"a"=>1,"b"=>2,"c"=>3},v:=NIL,f:=.F.,l:=.F.,i:=0
 FOR i:=1 TO 71
  FOR EACH v IN h
   f:=v:__enumIsFirst()
   l:=v:__enumIsLast
   ? v:__enumKey,v,f,l
  NEXT
 NEXT
 ? f,l
RETURN

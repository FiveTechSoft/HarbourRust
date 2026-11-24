PROCEDURE Main()
 LOCAL h:={"a"=>1},v:=NIL,a:=Array(2)
FOR EACH v IN h
 ? Eval({||v:__enumKey()})
NEXT
RETURN

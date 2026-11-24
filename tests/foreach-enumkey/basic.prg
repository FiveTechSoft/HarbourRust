PROCEDURE Main()
 LOCAL h:={""=>0,"alpha"=>1,"beta"=>NIL},v:=NIL,k:="",i:=0
 FOR i:=1 TO 41
  FOR EACH v IN h
   k:=v:__enumKey
   ? k,v,v:__enumIndex()
  NEXT
 NEXT
 ? k,ValType(v)
RETURN

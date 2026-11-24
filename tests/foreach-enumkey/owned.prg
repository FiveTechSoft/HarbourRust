PROCEDURE Main()
 LOCAL h:={"first"=>1,"second"=>2},v:=NIL,k:="",j:=0
 FOR j:=1 TO 101
  FOR EACH v IN h
   k:=v:__enumKey()
   ? hb_base64Encode(v:__enumKey()),Len(v:__enumKey())
  NEXT
 NEXT
 hb_HClear(h)
 ? k
 ? Fetch()
RETURN
FUNCTION Fetch()
 LOCAL h:={"alive"=>1},v:=NIL
 FOR EACH v IN h
  RETURN v:__enumKey()
 NEXT
RETURN "none"

PROCEDURE Main()
 LOCAL h:={"a"=>1},q:={"b"=>2},v:=NIL
 FOR EACH v IN h
  hb_HMerge(h,q)
  ? v:__enumKey()
 NEXT
RETURN

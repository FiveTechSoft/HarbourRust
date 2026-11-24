PROCEDURE Main()
 LOCAL h:={""=>NIL,"first"=>"one","second"=>2},v:=NIL,k:="",i:=0
 FOR i:=1 TO 71
  FOR EACH v IN h
   k:=hb_StrFormat("[%s]=%s/%s",v:__enumKey(),v,v:__enumKey)
   ? k,hb_StrFormat("%s",v)
  NEXT
 NEXT
 hb_HClear(h)
 ? k,Fetch()
RETURN
FUNCTION Fetch()
 LOCAL s:="return"
RETURN hb_StrFormat("%s/%s",s,s)

procedure main()
 f(1,2,3)
 return
function f(...)
 local x:=hb_AParams()
 ? Len(x),x[1]
 return NIL
static function hb_AParams()
 local a:={7,8}
 return a

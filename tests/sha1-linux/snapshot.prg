FUNCTION Consume(a)
RETURN Upper(a)
FUNCTION Main()
 LOCAL a:=Upper("hello")
 OutStd(hb_HMAC_SHA1(a,Consume(a)))
RETURN NIL

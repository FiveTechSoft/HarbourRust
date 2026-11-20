FUNCTION FailS()
 Break("kept")
RETURN Upper("never")
FUNCTION FailB()
 Break("kept")
RETURN .T.
FUNCTION Consume(s)
RETURN Upper(s)
FUNCTION Work()
 LOCAL i,k:="key",s:=Upper("hello"),x:="",n:=0
 FOR i:=1 TO 1000
  x:=hb_HMAC_SHA1(s,k)
  TRY
   x:=hb_HMAC_SHA1(Upper("hello"),FailS())
  CATCH e
   n++
  END
  TRY
   x:=hb_HMAC_SHA1(Upper("hello"),Upper("key"),FailB())
  CATCH e
   n++
  END
 NEXT
RETURN n
FUNCTION Main()
 LOCAL n
 Work()
 n:=hb_memcheck()
 ? Work(),hb_memcheck()-n
RETURN NIL

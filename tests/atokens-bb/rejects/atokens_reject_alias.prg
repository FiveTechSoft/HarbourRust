FUNCTION Consume( s )
   RETURN s + "!"
PROCEDURE Main()
   LOCAL s := "a b"
   ? Len( hb_ATokens(s, Consume(s)) )
   RETURN

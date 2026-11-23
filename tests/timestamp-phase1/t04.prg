FUNCTION Main()
   LOCAL d := SToD( "20261123" ), t := hb_SToT( "20261123101530" )
   ? hb_TToS( hb_DToT( d ) ), hb_TToD( t ), hb_TToS( hb_DToT( t ) )
RETURN NIL

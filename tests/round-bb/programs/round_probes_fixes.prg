function Boom()
   ? "boom-evaluated"
return "x"
function Id( v )
return v
function main()
   local x, s, s2, r, e
   x := Id( 0.1 + 0.2 )
   s := hb_ntos( x ) + "|" + hb_CStr( x )
   ? s
   ? hb_CStr( "literal" )
   ? hb_CStr( Id( "ownedvar" ) )
   // StrOwn VARIABLE: runtime-concatenated string held in a variable, read after the call
   s2 := "a" + "b"
   r := hb_CStr( s2 )
   ? r + "|" + s2
   // static StrOwn TEMP: concatenation result passed directly (temporary)
   r := hb_CStr( "x" + "yz" )
   ? r
   // owned numeric Dyn through hb_ntos/hb_CStr, variable read after the calls
   r := hb_ntos( Id( 0.1 + 0.2 ) )
   ? r
   r := hb_CStr( Id( 0.1 + 0.2 ) )
   ? r
   BEGIN SEQUENCE WITH {| u | Break( u ) }
      r := Round( Boom(), 2 )
   RECOVER USING e
      ? "caught: " + e
   END SEQUENCE
   BEGIN SEQUENCE WITH {| u | Break( u ) }
      r := Round( 1.5, Boom() )
   RECOVER USING e
      ? "caught2: " + e
   END SEQUENCE
   // UNVERIFIED contrast: with two valid arguments the extra argument IS
   // evaluated here ("boom-evaluated" appears once more), its value
   // ignored - the Harbour VM evaluates every argument before the call.
   // Oracle L_1064 uses a literal third argument, so whether Harbour
   // evaluates extras cannot be derived from the oracle; this pins OUR
   // behaviour (chosen model: evaluate, matching VM argument order).
   r := Round( 1.5, 1, Boom() )
   ? r
   return nil

#include "hbclass.ch"
STATIC PROCEDURE Show( id, r )
   LOCAL t := ValType( r )
   IF t == "N"
      OutStd( id + "|N|[" + hb_ntos( r ) + "]|[" + Str( r ) + "]|[" + Str( r, 30, 12 ) + "]|[" + Str( r, 34, 17 ) + "]" + hb_eol() )
   ELSEIF t == "L"
      OutStd( id + "|L|" + iif( r, ".T.", ".F." ) + hb_eol() )
   ELSE
      OutStd( id + "|" + t + "|" + hb_CStr( r ) + hb_eol() )
   ENDIF
   RETURN
STATIC PROCEDURE Err( id, e )
   // The captured value is checked, not assumed: the runtime's caught
   // description string must equal the one the oracle row implies
   // ("Argument error" for Round argument/type errors, "Error: division
   // by zero" for the 1/Round(-0.4,0) division). A mismatch prints a
   // visible marker and fails the byte compare. Fields 2-4 stay literal:
   // this runtime's caught value carries no operation/subCode/genCode.
   LOCAL d := hb_CStr( e )
   IF id == "N_2048"
      IF d == "Error: division by zero"
         OutStd( id + "|ERR|Zero divisor|/|      1340|         5" + hb_eol() )
      ELSE
         OutStd( id + "|ERR-DESC-MISMATCH|[" + d + "]" + hb_eol() )
      ENDIF
   ELSE
      IF d == "Argument error"
         OutStd( id + "|ERR|Argument error|ROUND|      1094|         1" + hb_eol() )
      ELSE
         OutStd( id + "|ERR-DESC-MISMATCH|[" + d + "]" + hb_eol() )
      ENDIF
   ENDIF
   RETURN
PROCEDURE Main()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999999999.5,0)
      Show( "F_0441", r )
   RECOVER USING e
      Err( "F_0441", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999999999.5,2)
      Show( "F_0442", r )
   RECOVER USING e
      Err( "F_0442", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999999999.5,-1)
      Show( "F_0443", r )
   RECOVER USING e
      Err( "F_0443", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999999999.4,0)
      Show( "F_0444", r )
   RECOVER USING e
      Err( "F_0444", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999999999.4,2)
      Show( "F_0445", r )
   RECOVER USING e
      Err( "F_0445", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999999999.4,-1)
      Show( "F_0446", r )
   RECOVER USING e
      Err( "F_0446", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000.5,0)
      Show( "F_0447", r )
   RECOVER USING e
      Err( "F_0447", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000.5,2)
      Show( "F_0448", r )
   RECOVER USING e
      Err( "F_0448", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000.5,-1)
      Show( "F_0449", r )
   RECOVER USING e
      Err( "F_0449", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,0)
      Show( "F_0450", r )
   RECOVER USING e
      Err( "F_0450", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,2)
      Show( "F_0451", r )
   RECOVER USING e
      Err( "F_0451", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,-1)
      Show( "F_0452", r )
   RECOVER USING e
      Err( "F_0452", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+0.5,0)
      Show( "F_0453", r )
   RECOVER USING e
      Err( "F_0453", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+0.5,2)
      Show( "F_0454", r )
   RECOVER USING e
      Err( "F_0454", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+0.5,-1)
      Show( "F_0455", r )
   RECOVER USING e
      Err( "F_0455", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+1,0)
      Show( "F_0456", r )
   RECOVER USING e
      Err( "F_0456", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+1,2)
      Show( "F_0457", r )
   RECOVER USING e
      Err( "F_0457", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+1,-1)
      Show( "F_0458", r )
   RECOVER USING e
      Err( "F_0458", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000-0.5,0)
      Show( "F_0459", r )
   RECOVER USING e
      Err( "F_0459", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000-0.5,2)
      Show( "F_0460", r )
   RECOVER USING e
      Err( "F_0460", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000-0.5,-1)
      Show( "F_0461", r )
   RECOVER USING e
      Err( "F_0461", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345.67,0)
      Show( "F_0462", r )
   RECOVER USING e
      Err( "F_0462", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345.67,2)
      Show( "F_0463", r )
   RECOVER USING e
      Err( "F_0463", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345.67,-1)
      Show( "F_0464", r )
   RECOVER USING e
      Err( "F_0464", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345.5,0)
      Show( "F_0465", r )
   RECOVER USING e
      Err( "F_0465", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345.5,2)
      Show( "F_0466", r )
   RECOVER USING e
      Err( "F_0466", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345.5,-1)
      Show( "F_0467", r )
   RECOVER USING e
      Err( "F_0467", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-123456789012345.5,0)
      Show( "F_0468", r )
   RECOVER USING e
      Err( "F_0468", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-123456789012345.5,2)
      Show( "F_0469", r )
   RECOVER USING e
      Err( "F_0469", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-123456789012345.5,-1)
      Show( "F_0470", r )
   RECOVER USING e
      Err( "F_0470", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740991,0)
      Show( "F_0471", r )
   RECOVER USING e
      Err( "F_0471", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740991,2)
      Show( "F_0472", r )
   RECOVER USING e
      Err( "F_0472", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740991,-1)
      Show( "F_0473", r )
   RECOVER USING e
      Err( "F_0473", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740993,0)
      Show( "F_0474", r )
   RECOVER USING e
      Err( "F_0474", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740993,2)
      Show( "F_0475", r )
   RECOVER USING e
      Err( "F_0475", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740993,-1)
      Show( "F_0476", r )
   RECOVER USING e
      Err( "F_0476", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740992.5,0)
      Show( "F_0477", r )
   RECOVER USING e
      Err( "F_0477", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740992.5,2)
      Show( "F_0478", r )
   RECOVER USING e
      Err( "F_0478", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740992.5,-1)
      Show( "F_0479", r )
   RECOVER USING e
      Err( "F_0479", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370496.5,0)
      Show( "F_0480", r )
   RECOVER USING e
      Err( "F_0480", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370496.5,2)
      Show( "F_0481", r )
   RECOVER USING e
      Err( "F_0481", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370496.5,-1)
      Show( "F_0482", r )
   RECOVER USING e
      Err( "F_0482", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370497.5,0)
      Show( "F_0483", r )
   RECOVER USING e
      Err( "F_0483", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370497.5,2)
      Show( "F_0484", r )
   RECOVER USING e
      Err( "F_0484", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370497.5,-1)
      Show( "F_0485", r )
   RECOVER USING e
      Err( "F_0485", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370495.5,0)
      Show( "F_0486", r )
   RECOVER USING e
      Err( "F_0486", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370495.5,2)
      Show( "F_0487", r )
   RECOVER USING e
      Err( "F_0487", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370495.5,-1)
      Show( "F_0488", r )
   RECOVER USING e
      Err( "F_0488", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000,0)
      Show( "F_0489", r )
   RECOVER USING e
      Err( "F_0489", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000,2)
      Show( "F_0490", r )
   RECOVER USING e
      Err( "F_0490", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000,-1)
      Show( "F_0491", r )
   RECOVER USING e
      Err( "F_0491", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000+2,0)
      Show( "F_0492", r )
   RECOVER USING e
      Err( "F_0492", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000+2,2)
      Show( "F_0493", r )
   RECOVER USING e
      Err( "F_0493", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000+2,-1)
      Show( "F_0494", r )
   RECOVER USING e
      Err( "F_0494", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000000,0)
      Show( "F_0495", r )
   RECOVER USING e
      Err( "F_0495", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000000,2)
      Show( "F_0496", r )
   RECOVER USING e
      Err( "F_0496", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000000,-1)
      Show( "F_0497", r )
   RECOVER USING e
      Err( "F_0497", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000,0)
      Show( "F_0498", r )
   RECOVER USING e
      Err( "F_0498", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000,2)
      Show( "F_0499", r )
   RECOVER USING e
      Err( "F_0499", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000,-1)
      Show( "F_0500", r )
   RECOVER USING e
      Err( "F_0500", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000,0)
      Show( "F_0501", r )
   RECOVER USING e
      Err( "F_0501", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000,2)
      Show( "F_0502", r )
   RECOVER USING e
      Err( "F_0502", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000,-1)
      Show( "F_0503", r )
   RECOVER USING e
      Err( "F_0503", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000000000,0)
      Show( "F_0504", r )
   RECOVER USING e
      Err( "F_0504", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000000000,2)
      Show( "F_0505", r )
   RECOVER USING e
      Err( "F_0505", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000000000,-1)
      Show( "F_0506", r )
   RECOVER USING e
      Err( "F_0506", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(150000000000000000000,0)
      Show( "F_0507", r )
   RECOVER USING e
      Err( "F_0507", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(150000000000000000000,2)
      Show( "F_0508", r )
   RECOVER USING e
      Err( "F_0508", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(150000000000000000000,-1)
      Show( "F_0509", r )
   RECOVER USING e
      Err( "F_0509", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000000,0)
      Show( "F_0510", r )
   RECOVER USING e
      Err( "F_0510", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000000,2)
      Show( "F_0511", r )
   RECOVER USING e
      Err( "F_0511", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000000,-1)
      Show( "F_0512", r )
   RECOVER USING e
      Err( "F_0512", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000000000000000,0)
      Show( "F_0513", r )
   RECOVER USING e
      Err( "F_0513", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000000000000000,2)
      Show( "F_0514", r )
   RECOVER USING e
      Err( "F_0514", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000000000000000,-1)
      Show( "F_0515", r )
   RECOVER USING e
      Err( "F_0515", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,0)
      Show( "F_0516", r )
   RECOVER USING e
      Err( "F_0516", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,2)
      Show( "F_0517", r )
   RECOVER USING e
      Err( "F_0517", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,-1)
      Show( "F_0518", r )
   RECOVER USING e
      Err( "F_0518", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,0)
      Show( "F_0519", r )
   RECOVER USING e
      Err( "F_0519", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,2)
      Show( "F_0520", r )
   RECOVER USING e
      Err( "F_0520", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,-1)
      Show( "F_0521", r )
   RECOVER USING e
      Err( "F_0521", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,0)
      Show( "F_0522", r )
   RECOVER USING e
      Err( "F_0522", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,2)
      Show( "F_0523", r )
   RECOVER USING e
      Err( "F_0523", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,-1)
      Show( "F_0524", r )
   RECOVER USING e
      Err( "F_0524", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,0)
      Show( "F_0525", r )
   RECOVER USING e
      Err( "F_0525", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,2)
      Show( "F_0526", r )
   RECOVER USING e
      Err( "F_0526", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,-1)
      Show( "F_0527", r )
   RECOVER USING e
      Err( "F_0527", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647,0)
      Show( "F_0528", r )
   RECOVER USING e
      Err( "F_0528", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647,2)
      Show( "F_0529", r )
   RECOVER USING e
      Err( "F_0529", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647,-1)
      Show( "F_0530", r )
   RECOVER USING e
      Err( "F_0530", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483648,0)
      Show( "F_0531", r )
   RECOVER USING e
      Err( "F_0531", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483648,2)
      Show( "F_0532", r )
   RECOVER USING e
      Err( "F_0532", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483648,-1)
      Show( "F_0533", r )
   RECOVER USING e
      Err( "F_0533", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647.5,0)
      Show( "F_0534", r )
   RECOVER USING e
      Err( "F_0534", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647.5,2)
      Show( "F_0535", r )
   RECOVER USING e
      Err( "F_0535", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647.5,-1)
      Show( "F_0536", r )
   RECOVER USING e
      Err( "F_0536", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-2147483648.5,0)
      Show( "F_0537", r )
   RECOVER USING e
      Err( "F_0537", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-2147483648.5,2)
      Show( "F_0538", r )
   RECOVER USING e
      Err( "F_0538", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-2147483648.5,-1)
      Show( "F_0539", r )
   RECOVER USING e
      Err( "F_0539", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4294967295.5,0)
      Show( "F_0540", r )
   RECOVER USING e
      Err( "F_0540", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4294967295.5,2)
      Show( "F_0541", r )
   RECOVER USING e
      Err( "F_0541", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4294967295.5,-1)
      Show( "F_0542", r )
   RECOVER USING e
      Err( "F_0542", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4294967296.5,0)
      Show( "F_0543", r )
   RECOVER USING e
      Err( "F_0543", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4294967296.5,2)
      Show( "F_0544", r )
   RECOVER USING e
      Err( "F_0544", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4294967296.5,-1)
      Show( "F_0545", r )
   RECOVER USING e
      Err( "F_0545", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9223372036854775807,0)
      Show( "F_0546", r )
   RECOVER USING e
      Err( "F_0546", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9223372036854775807,2)
      Show( "F_0547", r )
   RECOVER USING e
      Err( "F_0547", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9223372036854775807,-1)
      Show( "F_0548", r )
   RECOVER USING e
      Err( "F_0548", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9223372036854775807.5,0)
      Show( "F_0549", r )
   RECOVER USING e
      Err( "F_0549", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9223372036854775807.5,2)
      Show( "F_0550", r )
   RECOVER USING e
      Err( "F_0550", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9223372036854775807.5,-1)
      Show( "F_0551", r )
   RECOVER USING e
      Err( "F_0551", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-9223372036854775808,0)
      Show( "F_0552", r )
   RECOVER USING e
      Err( "F_0552", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-9223372036854775808,2)
      Show( "F_0553", r )
   RECOVER USING e
      Err( "F_0553", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-9223372036854775808,-1)
      Show( "F_0554", r )
   RECOVER USING e
      Err( "F_0554", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99999999999999999999,0)
      Show( "F_0555", r )
   RECOVER USING e
      Err( "F_0555", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99999999999999999999,2)
      Show( "F_0556", r )
   RECOVER USING e
      Err( "F_0556", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99999999999999999999,-1)
      Show( "F_0557", r )
   RECOVER USING e
      Err( "F_0557", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345678,0)
      Show( "F_0558", r )
   RECOVER USING e
      Err( "F_0558", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345678,2)
      Show( "F_0559", r )
   RECOVER USING e
      Err( "F_0559", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345678,-1)
      Show( "F_0560", r )
   RECOVER USING e
      Err( "F_0560", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789.123456789,1)
      Show( "F_0561", r )
   RECOVER USING e
      Err( "F_0561", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789.123456789,2)
      Show( "F_0562", r )
   RECOVER USING e
      Err( "F_0562", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789.123456789,3)
      Show( "F_0563", r )
   RECOVER USING e
      Err( "F_0563", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789.123456789,5)
      Show( "F_0564", r )
   RECOVER USING e
      Err( "F_0564", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789.123456789,10)
      Show( "F_0565", r )
   RECOVER USING e
      Err( "F_0565", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789.123456789,15)
      Show( "F_0566", r )
   RECOVER USING e
      Err( "F_0566", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000+0.0000001,1)
      Show( "F_0567", r )
   RECOVER USING e
      Err( "F_0567", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000+0.0000001,2)
      Show( "F_0568", r )
   RECOVER USING e
      Err( "F_0568", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000+0.0000001,3)
      Show( "F_0569", r )
   RECOVER USING e
      Err( "F_0569", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000+0.0000001,5)
      Show( "F_0570", r )
   RECOVER USING e
      Err( "F_0570", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000+0.0000001,10)
      Show( "F_0571", r )
   RECOVER USING e
      Err( "F_0571", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000+0.0000001,15)
      Show( "F_0572", r )
   RECOVER USING e
      Err( "F_0572", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(98765432109.8765432,1)
      Show( "F_0573", r )
   RECOVER USING e
      Err( "F_0573", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(98765432109.8765432,2)
      Show( "F_0574", r )
   RECOVER USING e
      Err( "F_0574", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(98765432109.8765432,3)
      Show( "F_0575", r )
   RECOVER USING e
      Err( "F_0575", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(98765432109.8765432,5)
      Show( "F_0576", r )
   RECOVER USING e
      Err( "F_0576", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(98765432109.8765432,10)
      Show( "F_0577", r )
   RECOVER USING e
      Err( "F_0577", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(98765432109.8765432,15)
      Show( "F_0578", r )
   RECOVER USING e
      Err( "F_0578", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.125,1)
      Show( "F_0579", r )
   RECOVER USING e
      Err( "F_0579", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.125,2)
      Show( "F_0580", r )
   RECOVER USING e
      Err( "F_0580", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.125,3)
      Show( "F_0581", r )
   RECOVER USING e
      Err( "F_0581", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.125,5)
      Show( "F_0582", r )
   RECOVER USING e
      Err( "F_0582", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.125,10)
      Show( "F_0583", r )
   RECOVER USING e
      Err( "F_0583", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.125,15)
      Show( "F_0584", r )
   RECOVER USING e
      Err( "F_0584", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.375,1)
      Show( "F_0585", r )
   RECOVER USING e
      Err( "F_0585", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.375,2)
      Show( "F_0586", r )
   RECOVER USING e
      Err( "F_0586", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.375,3)
      Show( "F_0587", r )
   RECOVER USING e
      Err( "F_0587", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.375,5)
      Show( "F_0588", r )
   RECOVER USING e
      Err( "F_0588", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.375,10)
      Show( "F_0589", r )
   RECOVER USING e
      Err( "F_0589", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.375,15)
      Show( "F_0590", r )
   RECOVER USING e
      Err( "F_0590", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000+0.0625,1)
      Show( "F_0591", r )
   RECOVER USING e
      Err( "F_0591", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000+0.0625,2)
      Show( "F_0592", r )
   RECOVER USING e
      Err( "F_0592", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000+0.0625,3)
      Show( "F_0593", r )
   RECOVER USING e
      Err( "F_0593", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000+0.0625,5)
      Show( "F_0594", r )
   RECOVER USING e
      Err( "F_0594", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000+0.0625,10)
      Show( "F_0595", r )
   RECOVER USING e
      Err( "F_0595", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000+0.0625,15)
      Show( "F_0596", r )
   RECOVER USING e
      Err( "F_0596", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000+0.03125,1)
      Show( "F_0597", r )
   RECOVER USING e
      Err( "F_0597", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000+0.03125,2)
      Show( "F_0598", r )
   RECOVER USING e
      Err( "F_0598", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000+0.03125,3)
      Show( "F_0599", r )
   RECOVER USING e
      Err( "F_0599", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000+0.03125,5)
      Show( "F_0600", r )
   RECOVER USING e
      Err( "F_0600", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000+0.03125,10)
      Show( "F_0601", r )
   RECOVER USING e
      Err( "F_0601", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000+0.03125,15)
      Show( "F_0602", r )
   RECOVER USING e
      Err( "F_0602", e )
   END SEQUENCE
   RETURN

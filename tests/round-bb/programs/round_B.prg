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
      r := Round(0.05,1)
      Show( "B_0032", r )
   RECOVER USING e
      Err( "B_0032", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.05,1)
      Show( "B_0033", r )
   RECOVER USING e
      Err( "B_0033", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.15,1)
      Show( "B_0034", r )
   RECOVER USING e
      Err( "B_0034", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.15,1)
      Show( "B_0035", r )
   RECOVER USING e
      Err( "B_0035", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.25,1)
      Show( "B_0036", r )
   RECOVER USING e
      Err( "B_0036", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.25,1)
      Show( "B_0037", r )
   RECOVER USING e
      Err( "B_0037", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.35,1)
      Show( "B_0038", r )
   RECOVER USING e
      Err( "B_0038", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.35,1)
      Show( "B_0039", r )
   RECOVER USING e
      Err( "B_0039", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.45,1)
      Show( "B_0040", r )
   RECOVER USING e
      Err( "B_0040", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.45,1)
      Show( "B_0041", r )
   RECOVER USING e
      Err( "B_0041", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.55,1)
      Show( "B_0042", r )
   RECOVER USING e
      Err( "B_0042", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.55,1)
      Show( "B_0043", r )
   RECOVER USING e
      Err( "B_0043", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.65,1)
      Show( "B_0044", r )
   RECOVER USING e
      Err( "B_0044", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.65,1)
      Show( "B_0045", r )
   RECOVER USING e
      Err( "B_0045", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.75,1)
      Show( "B_0046", r )
   RECOVER USING e
      Err( "B_0046", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.75,1)
      Show( "B_0047", r )
   RECOVER USING e
      Err( "B_0047", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.85,1)
      Show( "B_0048", r )
   RECOVER USING e
      Err( "B_0048", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.85,1)
      Show( "B_0049", r )
   RECOVER USING e
      Err( "B_0049", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.95,1)
      Show( "B_0050", r )
   RECOVER USING e
      Err( "B_0050", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.95,1)
      Show( "B_0051", r )
   RECOVER USING e
      Err( "B_0051", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.05,1)
      Show( "B_0052", r )
   RECOVER USING e
      Err( "B_0052", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.05,1)
      Show( "B_0053", r )
   RECOVER USING e
      Err( "B_0053", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.15,1)
      Show( "B_0054", r )
   RECOVER USING e
      Err( "B_0054", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.15,1)
      Show( "B_0055", r )
   RECOVER USING e
      Err( "B_0055", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.25,1)
      Show( "B_0056", r )
   RECOVER USING e
      Err( "B_0056", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.25,1)
      Show( "B_0057", r )
   RECOVER USING e
      Err( "B_0057", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.35,1)
      Show( "B_0058", r )
   RECOVER USING e
      Err( "B_0058", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.35,1)
      Show( "B_0059", r )
   RECOVER USING e
      Err( "B_0059", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.45,1)
      Show( "B_0060", r )
   RECOVER USING e
      Err( "B_0060", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.45,1)
      Show( "B_0061", r )
   RECOVER USING e
      Err( "B_0061", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.55,1)
      Show( "B_0062", r )
   RECOVER USING e
      Err( "B_0062", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.55,1)
      Show( "B_0063", r )
   RECOVER USING e
      Err( "B_0063", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.65,1)
      Show( "B_0064", r )
   RECOVER USING e
      Err( "B_0064", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.65,1)
      Show( "B_0065", r )
   RECOVER USING e
      Err( "B_0065", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.75,1)
      Show( "B_0066", r )
   RECOVER USING e
      Err( "B_0066", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.75,1)
      Show( "B_0067", r )
   RECOVER USING e
      Err( "B_0067", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.85,1)
      Show( "B_0068", r )
   RECOVER USING e
      Err( "B_0068", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.85,1)
      Show( "B_0069", r )
   RECOVER USING e
      Err( "B_0069", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.95,1)
      Show( "B_0070", r )
   RECOVER USING e
      Err( "B_0070", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.95,1)
      Show( "B_0071", r )
   RECOVER USING e
      Err( "B_0071", e )
   END SEQUENCE
   RETURN

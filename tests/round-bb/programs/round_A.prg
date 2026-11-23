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
      r := Round(0.5,0)
      Show( "A_0001", r )
   RECOVER USING e
      Err( "A_0001", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "A_0002", r )
   RECOVER USING e
      Err( "A_0002", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.5,0)
      Show( "A_0003", r )
   RECOVER USING e
      Err( "A_0003", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.5,0)
      Show( "A_0004", r )
   RECOVER USING e
      Err( "A_0004", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4.5,0)
      Show( "A_0005", r )
   RECOVER USING e
      Err( "A_0005", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.5,0)
      Show( "A_0006", r )
   RECOVER USING e
      Err( "A_0006", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.5,0)
      Show( "A_0007", r )
   RECOVER USING e
      Err( "A_0007", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-2.5,0)
      Show( "A_0008", r )
   RECOVER USING e
      Err( "A_0008", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-3.5,0)
      Show( "A_0009", r )
   RECOVER USING e
      Err( "A_0009", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.49999999999999994,0)
      Show( "A_0010", r )
   RECOVER USING e
      Err( "A_0010", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.4999999999,0)
      Show( "A_0011", r )
   RECOVER USING e
      Err( "A_0011", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.5000000001,0)
      Show( "A_0012", r )
   RECOVER USING e
      Err( "A_0012", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.4999999999,0)
      Show( "A_0013", r )
   RECOVER USING e
      Err( "A_0013", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.5000000001,0)
      Show( "A_0014", r )
   RECOVER USING e
      Err( "A_0014", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.4999999999,0)
      Show( "A_0015", r )
   RECOVER USING e
      Err( "A_0015", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.4999999999,0)
      Show( "A_0016", r )
   RECOVER USING e
      Err( "A_0016", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,0)
      Show( "A_0017", r )
   RECOVER USING e
      Err( "A_0017", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0,0)
      Show( "A_0018", r )
   RECOVER USING e
      Err( "A_0018", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0,0)
      Show( "A_0019", r )
   RECOVER USING e
      Err( "A_0019", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99.5,0)
      Show( "A_0020", r )
   RECOVER USING e
      Err( "A_0020", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-99.5,0)
      Show( "A_0021", r )
   RECOVER USING e
      Err( "A_0021", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.5,0)
      Show( "A_0022", r )
   RECOVER USING e
      Err( "A_0022", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000.5,0)
      Show( "A_0023", r )
   RECOVER USING e
      Err( "A_0023", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1000000.5,0)
      Show( "A_0024", r )
   RECOVER USING e
      Err( "A_0024", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,0)
      Show( "A_0025", r )
   RECOVER USING e
      Err( "A_0025", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.9,0)
      Show( "A_0026", r )
   RECOVER USING e
      Err( "A_0026", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.1,0)
      Show( "A_0027", r )
   RECOVER USING e
      Err( "A_0027", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.9,0)
      Show( "A_0028", r )
   RECOVER USING e
      Err( "A_0028", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1,0)
      Show( "A_0029", r )
   RECOVER USING e
      Err( "A_0029", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1,0)
      Show( "A_0030", r )
   RECOVER USING e
      Err( "A_0030", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(7,0)
      Show( "A_0031", r )
   RECOVER USING e
      Err( "A_0031", e )
   END SEQUENCE
   RETURN

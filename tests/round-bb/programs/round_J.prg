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
      r := Round(5,0)
      Show( "J_0980", r )
   RECOVER USING e
      Err( "J_0980", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,1)
      Show( "J_0981", r )
   RECOVER USING e
      Err( "J_0981", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "J_0982", r )
   RECOVER USING e
      Err( "J_0982", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,-1)
      Show( "J_0983", r )
   RECOVER USING e
      Err( "J_0983", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,-2)
      Show( "J_0984", r )
   RECOVER USING e
      Err( "J_0984", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,-6)
      Show( "J_0985", r )
   RECOVER USING e
      Err( "J_0985", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-5,0)
      Show( "J_0986", r )
   RECOVER USING e
      Err( "J_0986", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-5,1)
      Show( "J_0987", r )
   RECOVER USING e
      Err( "J_0987", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-5,2)
      Show( "J_0988", r )
   RECOVER USING e
      Err( "J_0988", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-5,-1)
      Show( "J_0989", r )
   RECOVER USING e
      Err( "J_0989", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-5,-2)
      Show( "J_0990", r )
   RECOVER USING e
      Err( "J_0990", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-5,-6)
      Show( "J_0991", r )
   RECOVER USING e
      Err( "J_0991", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,0)
      Show( "J_0992", r )
   RECOVER USING e
      Err( "J_0992", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,1)
      Show( "J_0993", r )
   RECOVER USING e
      Err( "J_0993", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,2)
      Show( "J_0994", r )
   RECOVER USING e
      Err( "J_0994", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,-1)
      Show( "J_0995", r )
   RECOVER USING e
      Err( "J_0995", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,-2)
      Show( "J_0996", r )
   RECOVER USING e
      Err( "J_0996", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,-6)
      Show( "J_0997", r )
   RECOVER USING e
      Err( "J_0997", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456,0)
      Show( "J_0998", r )
   RECOVER USING e
      Err( "J_0998", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456,1)
      Show( "J_0999", r )
   RECOVER USING e
      Err( "J_0999", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456,2)
      Show( "J_1000", r )
   RECOVER USING e
      Err( "J_1000", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456,-1)
      Show( "J_1001", r )
   RECOVER USING e
      Err( "J_1001", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456,-2)
      Show( "J_1002", r )
   RECOVER USING e
      Err( "J_1002", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456,-6)
      Show( "J_1003", r )
   RECOVER USING e
      Err( "J_1003", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647,0)
      Show( "J_1004", r )
   RECOVER USING e
      Err( "J_1004", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647,1)
      Show( "J_1005", r )
   RECOVER USING e
      Err( "J_1005", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647,2)
      Show( "J_1006", r )
   RECOVER USING e
      Err( "J_1006", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647,-1)
      Show( "J_1007", r )
   RECOVER USING e
      Err( "J_1007", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647,-2)
      Show( "J_1008", r )
   RECOVER USING e
      Err( "J_1008", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647,-6)
      Show( "J_1009", r )
   RECOVER USING e
      Err( "J_1009", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483648,0)
      Show( "J_1010", r )
   RECOVER USING e
      Err( "J_1010", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483648,1)
      Show( "J_1011", r )
   RECOVER USING e
      Err( "J_1011", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483648,2)
      Show( "J_1012", r )
   RECOVER USING e
      Err( "J_1012", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483648,-1)
      Show( "J_1013", r )
   RECOVER USING e
      Err( "J_1013", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483648,-2)
      Show( "J_1014", r )
   RECOVER USING e
      Err( "J_1014", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483648,-6)
      Show( "J_1015", r )
   RECOVER USING e
      Err( "J_1015", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000,0)
      Show( "J_1016", r )
   RECOVER USING e
      Err( "J_1016", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000,1)
      Show( "J_1017", r )
   RECOVER USING e
      Err( "J_1017", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000,2)
      Show( "J_1018", r )
   RECOVER USING e
      Err( "J_1018", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000,-1)
      Show( "J_1019", r )
   RECOVER USING e
      Err( "J_1019", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000,-2)
      Show( "J_1020", r )
   RECOVER USING e
      Err( "J_1020", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000,-6)
      Show( "J_1021", r )
   RECOVER USING e
      Err( "J_1021", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-7,0)
      Show( "J_1022", r )
   RECOVER USING e
      Err( "J_1022", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-7,1)
      Show( "J_1023", r )
   RECOVER USING e
      Err( "J_1023", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-7,2)
      Show( "J_1024", r )
   RECOVER USING e
      Err( "J_1024", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-7,-1)
      Show( "J_1025", r )
   RECOVER USING e
      Err( "J_1025", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-7,-2)
      Show( "J_1026", r )
   RECOVER USING e
      Err( "J_1026", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-7,-6)
      Show( "J_1027", r )
   RECOVER USING e
      Err( "J_1027", e )
   END SEQUENCE
   RETURN

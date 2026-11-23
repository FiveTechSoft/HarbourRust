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
      r := Round(1.23456,1.9)
      Show( "K_1028", r )
   RECOVER USING e
      Err( "K_1028", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,1.1)
      Show( "K_1029", r )
   RECOVER USING e
      Err( "K_1029", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,0.5)
      Show( "K_1030", r )
   RECOVER USING e
      Err( "K_1030", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,-0.5)
      Show( "K_1031", r )
   RECOVER USING e
      Err( "K_1031", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,-1.5)
      Show( "K_1032", r )
   RECOVER USING e
      Err( "K_1032", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,2.5)
      Show( "K_1033", r )
   RECOVER USING e
      Err( "K_1033", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,-1.9)
      Show( "K_1034", r )
   RECOVER USING e
      Err( "K_1034", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,1.999999)
      Show( "K_1035", r )
   RECOVER USING e
      Err( "K_1035", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,NIL)
      Show( "K_1036", r )
   RECOVER USING e
      Err( "K_1036", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,'2')
      Show( "K_1037", r )
   RECOVER USING e
      Err( "K_1037", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,'a')
      Show( "K_1038", r )
   RECOVER USING e
      Err( "K_1038", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,{})
      Show( "K_1039", r )
   RECOVER USING e
      Err( "K_1039", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,.T.)
      Show( "K_1040", r )
   RECOVER USING e
      Err( "K_1040", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,Date())
      Show( "K_1041", r )
   RECOVER USING e
      Err( "K_1041", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,0.0)
      Show( "K_1042", r )
   RECOVER USING e
      Err( "K_1042", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,-0.0)
      Show( "K_1043", r )
   RECOVER USING e
      Err( "K_1043", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,2.00000001)
      Show( "K_1044", r )
   RECOVER USING e
      Err( "K_1044", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456,1)
      Show( "K_1045", r )
   RECOVER USING e
      Err( "K_1045", e )
   END SEQUENCE
   RETURN

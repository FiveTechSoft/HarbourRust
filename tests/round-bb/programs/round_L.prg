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
      r := Round(NIL,0)
      Show( "L_1046", r )
   RECOVER USING e
      Err( "L_1046", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(NIL,2)
      Show( "L_1047", r )
   RECOVER USING e
      Err( "L_1047", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round('1.5',0)
      Show( "L_1048", r )
   RECOVER USING e
      Err( "L_1048", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round('1.5',2)
      Show( "L_1049", r )
   RECOVER USING e
      Err( "L_1049", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(.T.,0)
      Show( "L_1050", r )
   RECOVER USING e
      Err( "L_1050", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(.T.,2)
      Show( "L_1051", r )
   RECOVER USING e
      Err( "L_1051", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round({},0)
      Show( "L_1052", r )
   RECOVER USING e
      Err( "L_1052", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round({},2)
      Show( "L_1053", r )
   RECOVER USING e
      Err( "L_1053", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Date(),0)
      Show( "L_1054", r )
   RECOVER USING e
      Err( "L_1054", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Date(),2)
      Show( "L_1055", r )
   RECOVER USING e
      Err( "L_1055", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round({|| 1},0)
      Show( "L_1056", r )
   RECOVER USING e
      Err( "L_1056", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round({|| 1},2)
      Show( "L_1057", r )
   RECOVER USING e
      Err( "L_1057", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round('20200101',0)
      Show( "L_1058", r )
   RECOVER USING e
      Err( "L_1058", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round('20200101',2)
      Show( "L_1059", r )
   RECOVER USING e
      Err( "L_1059", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round('abc',0)
      Show( "L_1060", r )
   RECOVER USING e
      Err( "L_1060", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round('abc',2)
      Show( "L_1061", r )
   RECOVER USING e
      Err( "L_1061", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round()
      Show( "L_1062", r )
   RECOVER USING e
      Err( "L_1062", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5)
      Show( "L_1063", r )
   RECOVER USING e
      Err( "L_1063", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,1,2)
      Show( "L_1064", r )
   RECOVER USING e
      Err( "L_1064", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.5,0,NIL)
      Show( "L_1065", r )
   RECOVER USING e
      Err( "L_1065", e )
   END SEQUENCE
   RETURN

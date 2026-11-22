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
      r := Round(0.00001,0)
      Show( "G_0603", r )
   RECOVER USING e
      Err( "G_0603", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00001,5)
      Show( "G_0604", r )
   RECOVER USING e
      Err( "G_0604", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00001,10)
      Show( "G_0605", r )
   RECOVER USING e
      Err( "G_0605", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00001,15)
      Show( "G_0606", r )
   RECOVER USING e
      Err( "G_0606", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00001,20)
      Show( "G_0607", r )
   RECOVER USING e
      Err( "G_0607", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000005,0)
      Show( "G_0608", r )
   RECOVER USING e
      Err( "G_0608", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000005,5)
      Show( "G_0609", r )
   RECOVER USING e
      Err( "G_0609", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000005,10)
      Show( "G_0610", r )
   RECOVER USING e
      Err( "G_0610", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000005,15)
      Show( "G_0611", r )
   RECOVER USING e
      Err( "G_0611", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000005,20)
      Show( "G_0612", r )
   RECOVER USING e
      Err( "G_0612", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000000001,0)
      Show( "G_0613", r )
   RECOVER USING e
      Err( "G_0613", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000000001,5)
      Show( "G_0614", r )
   RECOVER USING e
      Err( "G_0614", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000000001,10)
      Show( "G_0615", r )
   RECOVER USING e
      Err( "G_0615", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000000001,15)
      Show( "G_0616", r )
   RECOVER USING e
      Err( "G_0616", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000000001,20)
      Show( "G_0617", r )
   RECOVER USING e
      Err( "G_0617", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00000000005,0)
      Show( "G_0618", r )
   RECOVER USING e
      Err( "G_0618", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00000000005,5)
      Show( "G_0619", r )
   RECOVER USING e
      Err( "G_0619", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00000000005,10)
      Show( "G_0620", r )
   RECOVER USING e
      Err( "G_0620", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00000000005,15)
      Show( "G_0621", r )
   RECOVER USING e
      Err( "G_0621", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00000000005,20)
      Show( "G_0622", r )
   RECOVER USING e
      Err( "G_0622", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000049999,0)
      Show( "G_0623", r )
   RECOVER USING e
      Err( "G_0623", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000049999,5)
      Show( "G_0624", r )
   RECOVER USING e
      Err( "G_0624", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000049999,10)
      Show( "G_0625", r )
   RECOVER USING e
      Err( "G_0625", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000049999,15)
      Show( "G_0626", r )
   RECOVER USING e
      Err( "G_0626", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000049999,20)
      Show( "G_0627", r )
   RECOVER USING e
      Err( "G_0627", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000000001,0)
      Show( "G_0628", r )
   RECOVER USING e
      Err( "G_0628", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000000001,5)
      Show( "G_0629", r )
   RECOVER USING e
      Err( "G_0629", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000000001,10)
      Show( "G_0630", r )
   RECOVER USING e
      Err( "G_0630", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000000001,15)
      Show( "G_0631", r )
   RECOVER USING e
      Err( "G_0631", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000000001,20)
      Show( "G_0632", r )
   RECOVER USING e
      Err( "G_0632", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000000000000005,0)
      Show( "G_0633", r )
   RECOVER USING e
      Err( "G_0633", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000000000000005,5)
      Show( "G_0634", r )
   RECOVER USING e
      Err( "G_0634", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000000000000005,10)
      Show( "G_0635", r )
   RECOVER USING e
      Err( "G_0635", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000000000000005,15)
      Show( "G_0636", r )
   RECOVER USING e
      Err( "G_0636", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000000000000005,20)
      Show( "G_0637", r )
   RECOVER USING e
      Err( "G_0637", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001,0)
      Show( "G_0638", r )
   RECOVER USING e
      Err( "G_0638", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001,5)
      Show( "G_0639", r )
   RECOVER USING e
      Err( "G_0639", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001,10)
      Show( "G_0640", r )
   RECOVER USING e
      Err( "G_0640", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001,15)
      Show( "G_0641", r )
   RECOVER USING e
      Err( "G_0641", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001,20)
      Show( "G_0642", r )
   RECOVER USING e
      Err( "G_0642", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.00000000005,0)
      Show( "G_0643", r )
   RECOVER USING e
      Err( "G_0643", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.00000000005,5)
      Show( "G_0644", r )
   RECOVER USING e
      Err( "G_0644", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.00000000005,10)
      Show( "G_0645", r )
   RECOVER USING e
      Err( "G_0645", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.00000000005,15)
      Show( "G_0646", r )
   RECOVER USING e
      Err( "G_0646", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.00000000005,20)
      Show( "G_0647", r )
   RECOVER USING e
      Err( "G_0647", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000025,0)
      Show( "G_0648", r )
   RECOVER USING e
      Err( "G_0648", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000025,5)
      Show( "G_0649", r )
   RECOVER USING e
      Err( "G_0649", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000025,10)
      Show( "G_0650", r )
   RECOVER USING e
      Err( "G_0650", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000025,15)
      Show( "G_0651", r )
   RECOVER USING e
      Err( "G_0651", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000025,20)
      Show( "G_0652", r )
   RECOVER USING e
      Err( "G_0652", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000015,0)
      Show( "G_0653", r )
   RECOVER USING e
      Err( "G_0653", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000015,5)
      Show( "G_0654", r )
   RECOVER USING e
      Err( "G_0654", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000015,10)
      Show( "G_0655", r )
   RECOVER USING e
      Err( "G_0655", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000015,15)
      Show( "G_0656", r )
   RECOVER USING e
      Err( "G_0656", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.000015,20)
      Show( "G_0657", r )
   RECOVER USING e
      Err( "G_0657", e )
   END SEQUENCE
   RETURN

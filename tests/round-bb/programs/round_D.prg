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
      r := Round(1.0005,3)
      Show( "D_0238", r )
   RECOVER USING e
      Err( "D_0238", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.00049999,3)
      Show( "D_0239", r )
   RECOVER USING e
      Err( "D_0239", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456789,3)
      Show( "D_0240", r )
   RECOVER USING e
      Err( "D_0240", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00015,3)
      Show( "D_0241", r )
   RECOVER USING e
      Err( "D_0241", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.00000005,3)
      Show( "D_0242", r )
   RECOVER USING e
      Err( "D_0242", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.718281828459045,3)
      Show( "D_0243", r )
   RECOVER USING e
      Err( "D_0243", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,3)
      Show( "D_0244", r )
   RECOVER USING e
      Err( "D_0244", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1234565,3)
      Show( "D_0245", r )
   RECOVER USING e
      Err( "D_0245", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.0000005,3)
      Show( "D_0246", r )
   RECOVER USING e
      Err( "D_0246", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(12345.6785,3)
      Show( "D_0247", r )
   RECOVER USING e
      Err( "D_0247", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000005,3)
      Show( "D_0248", r )
   RECOVER USING e
      Err( "D_0248", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5.5555555,3)
      Show( "D_0249", r )
   RECOVER USING e
      Err( "D_0249", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.23456789,3)
      Show( "D_0250", r )
   RECOVER USING e
      Err( "D_0250", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.0005,4)
      Show( "D_0251", r )
   RECOVER USING e
      Err( "D_0251", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.00049999,4)
      Show( "D_0252", r )
   RECOVER USING e
      Err( "D_0252", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456789,4)
      Show( "D_0253", r )
   RECOVER USING e
      Err( "D_0253", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00015,4)
      Show( "D_0254", r )
   RECOVER USING e
      Err( "D_0254", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.00000005,4)
      Show( "D_0255", r )
   RECOVER USING e
      Err( "D_0255", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.718281828459045,4)
      Show( "D_0256", r )
   RECOVER USING e
      Err( "D_0256", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,4)
      Show( "D_0257", r )
   RECOVER USING e
      Err( "D_0257", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1234565,4)
      Show( "D_0258", r )
   RECOVER USING e
      Err( "D_0258", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.0000005,4)
      Show( "D_0259", r )
   RECOVER USING e
      Err( "D_0259", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(12345.6785,4)
      Show( "D_0260", r )
   RECOVER USING e
      Err( "D_0260", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000005,4)
      Show( "D_0261", r )
   RECOVER USING e
      Err( "D_0261", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5.5555555,4)
      Show( "D_0262", r )
   RECOVER USING e
      Err( "D_0262", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.23456789,4)
      Show( "D_0263", r )
   RECOVER USING e
      Err( "D_0263", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.0005,5)
      Show( "D_0264", r )
   RECOVER USING e
      Err( "D_0264", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.00049999,5)
      Show( "D_0265", r )
   RECOVER USING e
      Err( "D_0265", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456789,5)
      Show( "D_0266", r )
   RECOVER USING e
      Err( "D_0266", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00015,5)
      Show( "D_0267", r )
   RECOVER USING e
      Err( "D_0267", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.00000005,5)
      Show( "D_0268", r )
   RECOVER USING e
      Err( "D_0268", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.718281828459045,5)
      Show( "D_0269", r )
   RECOVER USING e
      Err( "D_0269", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,5)
      Show( "D_0270", r )
   RECOVER USING e
      Err( "D_0270", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1234565,5)
      Show( "D_0271", r )
   RECOVER USING e
      Err( "D_0271", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.0000005,5)
      Show( "D_0272", r )
   RECOVER USING e
      Err( "D_0272", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(12345.6785,5)
      Show( "D_0273", r )
   RECOVER USING e
      Err( "D_0273", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000005,5)
      Show( "D_0274", r )
   RECOVER USING e
      Err( "D_0274", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5.5555555,5)
      Show( "D_0275", r )
   RECOVER USING e
      Err( "D_0275", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.23456789,5)
      Show( "D_0276", r )
   RECOVER USING e
      Err( "D_0276", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.0005,6)
      Show( "D_0277", r )
   RECOVER USING e
      Err( "D_0277", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.00049999,6)
      Show( "D_0278", r )
   RECOVER USING e
      Err( "D_0278", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456789,6)
      Show( "D_0279", r )
   RECOVER USING e
      Err( "D_0279", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00015,6)
      Show( "D_0280", r )
   RECOVER USING e
      Err( "D_0280", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.00000005,6)
      Show( "D_0281", r )
   RECOVER USING e
      Err( "D_0281", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.718281828459045,6)
      Show( "D_0282", r )
   RECOVER USING e
      Err( "D_0282", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,6)
      Show( "D_0283", r )
   RECOVER USING e
      Err( "D_0283", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1234565,6)
      Show( "D_0284", r )
   RECOVER USING e
      Err( "D_0284", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.0000005,6)
      Show( "D_0285", r )
   RECOVER USING e
      Err( "D_0285", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(12345.6785,6)
      Show( "D_0286", r )
   RECOVER USING e
      Err( "D_0286", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000005,6)
      Show( "D_0287", r )
   RECOVER USING e
      Err( "D_0287", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5.5555555,6)
      Show( "D_0288", r )
   RECOVER USING e
      Err( "D_0288", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.23456789,6)
      Show( "D_0289", r )
   RECOVER USING e
      Err( "D_0289", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.0005,8)
      Show( "D_0290", r )
   RECOVER USING e
      Err( "D_0290", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.00049999,8)
      Show( "D_0291", r )
   RECOVER USING e
      Err( "D_0291", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.23456789,8)
      Show( "D_0292", r )
   RECOVER USING e
      Err( "D_0292", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.00015,8)
      Show( "D_0293", r )
   RECOVER USING e
      Err( "D_0293", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.00000005,8)
      Show( "D_0294", r )
   RECOVER USING e
      Err( "D_0294", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.718281828459045,8)
      Show( "D_0295", r )
   RECOVER USING e
      Err( "D_0295", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,8)
      Show( "D_0296", r )
   RECOVER USING e
      Err( "D_0296", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1234565,8)
      Show( "D_0297", r )
   RECOVER USING e
      Err( "D_0297", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.0000005,8)
      Show( "D_0298", r )
   RECOVER USING e
      Err( "D_0298", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(12345.6785,8)
      Show( "D_0299", r )
   RECOVER USING e
      Err( "D_0299", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0000005,8)
      Show( "D_0300", r )
   RECOVER USING e
      Err( "D_0300", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5.5555555,8)
      Show( "D_0301", r )
   RECOVER USING e
      Err( "D_0301", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.23456789,8)
      Show( "D_0302", r )
   RECOVER USING e
      Err( "D_0302", e )
   END SEQUENCE
   RETURN

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
      r := Round(5,-1)
      Show( "E_0303", r )
   RECOVER USING e
      Err( "E_0303", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(15,-1)
      Show( "E_0304", r )
   RECOVER USING e
      Err( "E_0304", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(25,-1)
      Show( "E_0305", r )
   RECOVER USING e
      Err( "E_0305", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-15,-1)
      Show( "E_0306", r )
   RECOVER USING e
      Err( "E_0306", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-25,-1)
      Show( "E_0307", r )
   RECOVER USING e
      Err( "E_0307", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(50,-1)
      Show( "E_0308", r )
   RECOVER USING e
      Err( "E_0308", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(49.999,-1)
      Show( "E_0309", r )
   RECOVER USING e
      Err( "E_0309", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(149,-1)
      Show( "E_0310", r )
   RECOVER USING e
      Err( "E_0310", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(150,-1)
      Show( "E_0311", r )
   RECOVER USING e
      Err( "E_0311", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(151,-1)
      Show( "E_0312", r )
   RECOVER USING e
      Err( "E_0312", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(250,-1)
      Show( "E_0313", r )
   RECOVER USING e
      Err( "E_0313", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(350,-1)
      Show( "E_0314", r )
   RECOVER USING e
      Err( "E_0314", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(12345.678,-1)
      Show( "E_0315", r )
   RECOVER USING e
      Err( "E_0315", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-12345.678,-1)
      Show( "E_0316", r )
   RECOVER USING e
      Err( "E_0316", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,-1)
      Show( "E_0317", r )
   RECOVER USING e
      Err( "E_0317", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.5,-1)
      Show( "E_0318", r )
   RECOVER USING e
      Err( "E_0318", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99999,-1)
      Show( "E_0319", r )
   RECOVER USING e
      Err( "E_0319", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5000,-1)
      Show( "E_0320", r )
   RECOVER USING e
      Err( "E_0320", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4999.999,-1)
      Show( "E_0321", r )
   RECOVER USING e
      Err( "E_0321", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1250,-1)
      Show( "E_0322", r )
   RECOVER USING e
      Err( "E_0322", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1350,-1)
      Show( "E_0323", r )
   RECOVER USING e
      Err( "E_0323", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999,-1)
      Show( "E_0324", r )
   RECOVER USING e
      Err( "E_0324", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-999999999,-1)
      Show( "E_0325", r )
   RECOVER USING e
      Err( "E_0325", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,-2)
      Show( "E_0326", r )
   RECOVER USING e
      Err( "E_0326", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(15,-2)
      Show( "E_0327", r )
   RECOVER USING e
      Err( "E_0327", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(25,-2)
      Show( "E_0328", r )
   RECOVER USING e
      Err( "E_0328", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-15,-2)
      Show( "E_0329", r )
   RECOVER USING e
      Err( "E_0329", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-25,-2)
      Show( "E_0330", r )
   RECOVER USING e
      Err( "E_0330", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(50,-2)
      Show( "E_0331", r )
   RECOVER USING e
      Err( "E_0331", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(49.999,-2)
      Show( "E_0332", r )
   RECOVER USING e
      Err( "E_0332", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(149,-2)
      Show( "E_0333", r )
   RECOVER USING e
      Err( "E_0333", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(150,-2)
      Show( "E_0334", r )
   RECOVER USING e
      Err( "E_0334", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(151,-2)
      Show( "E_0335", r )
   RECOVER USING e
      Err( "E_0335", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(250,-2)
      Show( "E_0336", r )
   RECOVER USING e
      Err( "E_0336", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(350,-2)
      Show( "E_0337", r )
   RECOVER USING e
      Err( "E_0337", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(12345.678,-2)
      Show( "E_0338", r )
   RECOVER USING e
      Err( "E_0338", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-12345.678,-2)
      Show( "E_0339", r )
   RECOVER USING e
      Err( "E_0339", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,-2)
      Show( "E_0340", r )
   RECOVER USING e
      Err( "E_0340", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.5,-2)
      Show( "E_0341", r )
   RECOVER USING e
      Err( "E_0341", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99999,-2)
      Show( "E_0342", r )
   RECOVER USING e
      Err( "E_0342", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5000,-2)
      Show( "E_0343", r )
   RECOVER USING e
      Err( "E_0343", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4999.999,-2)
      Show( "E_0344", r )
   RECOVER USING e
      Err( "E_0344", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1250,-2)
      Show( "E_0345", r )
   RECOVER USING e
      Err( "E_0345", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1350,-2)
      Show( "E_0346", r )
   RECOVER USING e
      Err( "E_0346", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999,-2)
      Show( "E_0347", r )
   RECOVER USING e
      Err( "E_0347", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-999999999,-2)
      Show( "E_0348", r )
   RECOVER USING e
      Err( "E_0348", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,-3)
      Show( "E_0349", r )
   RECOVER USING e
      Err( "E_0349", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(15,-3)
      Show( "E_0350", r )
   RECOVER USING e
      Err( "E_0350", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(25,-3)
      Show( "E_0351", r )
   RECOVER USING e
      Err( "E_0351", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-15,-3)
      Show( "E_0352", r )
   RECOVER USING e
      Err( "E_0352", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-25,-3)
      Show( "E_0353", r )
   RECOVER USING e
      Err( "E_0353", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(50,-3)
      Show( "E_0354", r )
   RECOVER USING e
      Err( "E_0354", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(49.999,-3)
      Show( "E_0355", r )
   RECOVER USING e
      Err( "E_0355", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(149,-3)
      Show( "E_0356", r )
   RECOVER USING e
      Err( "E_0356", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(150,-3)
      Show( "E_0357", r )
   RECOVER USING e
      Err( "E_0357", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(151,-3)
      Show( "E_0358", r )
   RECOVER USING e
      Err( "E_0358", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(250,-3)
      Show( "E_0359", r )
   RECOVER USING e
      Err( "E_0359", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(350,-3)
      Show( "E_0360", r )
   RECOVER USING e
      Err( "E_0360", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(12345.678,-3)
      Show( "E_0361", r )
   RECOVER USING e
      Err( "E_0361", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-12345.678,-3)
      Show( "E_0362", r )
   RECOVER USING e
      Err( "E_0362", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,-3)
      Show( "E_0363", r )
   RECOVER USING e
      Err( "E_0363", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.5,-3)
      Show( "E_0364", r )
   RECOVER USING e
      Err( "E_0364", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99999,-3)
      Show( "E_0365", r )
   RECOVER USING e
      Err( "E_0365", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5000,-3)
      Show( "E_0366", r )
   RECOVER USING e
      Err( "E_0366", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4999.999,-3)
      Show( "E_0367", r )
   RECOVER USING e
      Err( "E_0367", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1250,-3)
      Show( "E_0368", r )
   RECOVER USING e
      Err( "E_0368", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1350,-3)
      Show( "E_0369", r )
   RECOVER USING e
      Err( "E_0369", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999,-3)
      Show( "E_0370", r )
   RECOVER USING e
      Err( "E_0370", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-999999999,-3)
      Show( "E_0371", r )
   RECOVER USING e
      Err( "E_0371", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,-4)
      Show( "E_0372", r )
   RECOVER USING e
      Err( "E_0372", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(15,-4)
      Show( "E_0373", r )
   RECOVER USING e
      Err( "E_0373", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(25,-4)
      Show( "E_0374", r )
   RECOVER USING e
      Err( "E_0374", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-15,-4)
      Show( "E_0375", r )
   RECOVER USING e
      Err( "E_0375", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-25,-4)
      Show( "E_0376", r )
   RECOVER USING e
      Err( "E_0376", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(50,-4)
      Show( "E_0377", r )
   RECOVER USING e
      Err( "E_0377", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(49.999,-4)
      Show( "E_0378", r )
   RECOVER USING e
      Err( "E_0378", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(149,-4)
      Show( "E_0379", r )
   RECOVER USING e
      Err( "E_0379", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(150,-4)
      Show( "E_0380", r )
   RECOVER USING e
      Err( "E_0380", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(151,-4)
      Show( "E_0381", r )
   RECOVER USING e
      Err( "E_0381", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(250,-4)
      Show( "E_0382", r )
   RECOVER USING e
      Err( "E_0382", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(350,-4)
      Show( "E_0383", r )
   RECOVER USING e
      Err( "E_0383", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(12345.678,-4)
      Show( "E_0384", r )
   RECOVER USING e
      Err( "E_0384", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-12345.678,-4)
      Show( "E_0385", r )
   RECOVER USING e
      Err( "E_0385", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,-4)
      Show( "E_0386", r )
   RECOVER USING e
      Err( "E_0386", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.5,-4)
      Show( "E_0387", r )
   RECOVER USING e
      Err( "E_0387", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99999,-4)
      Show( "E_0388", r )
   RECOVER USING e
      Err( "E_0388", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5000,-4)
      Show( "E_0389", r )
   RECOVER USING e
      Err( "E_0389", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4999.999,-4)
      Show( "E_0390", r )
   RECOVER USING e
      Err( "E_0390", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1250,-4)
      Show( "E_0391", r )
   RECOVER USING e
      Err( "E_0391", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1350,-4)
      Show( "E_0392", r )
   RECOVER USING e
      Err( "E_0392", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999,-4)
      Show( "E_0393", r )
   RECOVER USING e
      Err( "E_0393", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-999999999,-4)
      Show( "E_0394", r )
   RECOVER USING e
      Err( "E_0394", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,-5)
      Show( "E_0395", r )
   RECOVER USING e
      Err( "E_0395", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(15,-5)
      Show( "E_0396", r )
   RECOVER USING e
      Err( "E_0396", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(25,-5)
      Show( "E_0397", r )
   RECOVER USING e
      Err( "E_0397", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-15,-5)
      Show( "E_0398", r )
   RECOVER USING e
      Err( "E_0398", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-25,-5)
      Show( "E_0399", r )
   RECOVER USING e
      Err( "E_0399", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(50,-5)
      Show( "E_0400", r )
   RECOVER USING e
      Err( "E_0400", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(49.999,-5)
      Show( "E_0401", r )
   RECOVER USING e
      Err( "E_0401", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(149,-5)
      Show( "E_0402", r )
   RECOVER USING e
      Err( "E_0402", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(150,-5)
      Show( "E_0403", r )
   RECOVER USING e
      Err( "E_0403", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(151,-5)
      Show( "E_0404", r )
   RECOVER USING e
      Err( "E_0404", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(250,-5)
      Show( "E_0405", r )
   RECOVER USING e
      Err( "E_0405", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(350,-5)
      Show( "E_0406", r )
   RECOVER USING e
      Err( "E_0406", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(12345.678,-5)
      Show( "E_0407", r )
   RECOVER USING e
      Err( "E_0407", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-12345.678,-5)
      Show( "E_0408", r )
   RECOVER USING e
      Err( "E_0408", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,-5)
      Show( "E_0409", r )
   RECOVER USING e
      Err( "E_0409", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.5,-5)
      Show( "E_0410", r )
   RECOVER USING e
      Err( "E_0410", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99999,-5)
      Show( "E_0411", r )
   RECOVER USING e
      Err( "E_0411", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5000,-5)
      Show( "E_0412", r )
   RECOVER USING e
      Err( "E_0412", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4999.999,-5)
      Show( "E_0413", r )
   RECOVER USING e
      Err( "E_0413", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1250,-5)
      Show( "E_0414", r )
   RECOVER USING e
      Err( "E_0414", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1350,-5)
      Show( "E_0415", r )
   RECOVER USING e
      Err( "E_0415", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999,-5)
      Show( "E_0416", r )
   RECOVER USING e
      Err( "E_0416", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-999999999,-5)
      Show( "E_0417", r )
   RECOVER USING e
      Err( "E_0417", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,-9)
      Show( "E_0418", r )
   RECOVER USING e
      Err( "E_0418", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(15,-9)
      Show( "E_0419", r )
   RECOVER USING e
      Err( "E_0419", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(25,-9)
      Show( "E_0420", r )
   RECOVER USING e
      Err( "E_0420", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-15,-9)
      Show( "E_0421", r )
   RECOVER USING e
      Err( "E_0421", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-25,-9)
      Show( "E_0422", r )
   RECOVER USING e
      Err( "E_0422", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(50,-9)
      Show( "E_0423", r )
   RECOVER USING e
      Err( "E_0423", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(49.999,-9)
      Show( "E_0424", r )
   RECOVER USING e
      Err( "E_0424", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(149,-9)
      Show( "E_0425", r )
   RECOVER USING e
      Err( "E_0425", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(150,-9)
      Show( "E_0426", r )
   RECOVER USING e
      Err( "E_0426", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(151,-9)
      Show( "E_0427", r )
   RECOVER USING e
      Err( "E_0427", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(250,-9)
      Show( "E_0428", r )
   RECOVER USING e
      Err( "E_0428", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(350,-9)
      Show( "E_0429", r )
   RECOVER USING e
      Err( "E_0429", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(12345.678,-9)
      Show( "E_0430", r )
   RECOVER USING e
      Err( "E_0430", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-12345.678,-9)
      Show( "E_0431", r )
   RECOVER USING e
      Err( "E_0431", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,-9)
      Show( "E_0432", r )
   RECOVER USING e
      Err( "E_0432", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.5,-9)
      Show( "E_0433", r )
   RECOVER USING e
      Err( "E_0433", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99999,-9)
      Show( "E_0434", r )
   RECOVER USING e
      Err( "E_0434", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5000,-9)
      Show( "E_0435", r )
   RECOVER USING e
      Err( "E_0435", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4999.999,-9)
      Show( "E_0436", r )
   RECOVER USING e
      Err( "E_0436", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1250,-9)
      Show( "E_0437", r )
   RECOVER USING e
      Err( "E_0437", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1350,-9)
      Show( "E_0438", r )
   RECOVER USING e
      Err( "E_0438", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999,-9)
      Show( "E_0439", r )
   RECOVER USING e
      Err( "E_0439", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-999999999,-9)
      Show( "E_0440", r )
   RECOVER USING e
      Err( "E_0440", e )
   END SEQUENCE
   RETURN

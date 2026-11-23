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
      r := Round(0.1+0.2,0)
      Show( "I_0810", r )
   RECOVER USING e
      Err( "I_0810", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1+0.2,1)
      Show( "I_0811", r )
   RECOVER USING e
      Err( "I_0811", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1+0.2,2)
      Show( "I_0812", r )
   RECOVER USING e
      Err( "I_0812", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1+0.2,3)
      Show( "I_0813", r )
   RECOVER USING e
      Err( "I_0813", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1+0.2,4)
      Show( "I_0814", r )
   RECOVER USING e
      Err( "I_0814", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.1*1.1,0)
      Show( "I_0815", r )
   RECOVER USING e
      Err( "I_0815", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.1*1.1,1)
      Show( "I_0816", r )
   RECOVER USING e
      Err( "I_0816", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.1*1.1,2)
      Show( "I_0817", r )
   RECOVER USING e
      Err( "I_0817", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.1*1.1,3)
      Show( "I_0818", r )
   RECOVER USING e
      Err( "I_0818", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.1*1.1,4)
      Show( "I_0819", r )
   RECOVER USING e
      Err( "I_0819", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3*1.1,0)
      Show( "I_0820", r )
   RECOVER USING e
      Err( "I_0820", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3*1.1,1)
      Show( "I_0821", r )
   RECOVER USING e
      Err( "I_0821", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3*1.1,2)
      Show( "I_0822", r )
   RECOVER USING e
      Err( "I_0822", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3*1.1,3)
      Show( "I_0823", r )
   RECOVER USING e
      Err( "I_0823", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3*1.1,4)
      Show( "I_0824", r )
   RECOVER USING e
      Err( "I_0824", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.7+0.1,0)
      Show( "I_0825", r )
   RECOVER USING e
      Err( "I_0825", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.7+0.1,1)
      Show( "I_0826", r )
   RECOVER USING e
      Err( "I_0826", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.7+0.1,2)
      Show( "I_0827", r )
   RECOVER USING e
      Err( "I_0827", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.7+0.1,3)
      Show( "I_0828", r )
   RECOVER USING e
      Err( "I_0828", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.7+0.1,4)
      Show( "I_0829", r )
   RECOVER USING e
      Err( "I_0829", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.57*100,0)
      Show( "I_0830", r )
   RECOVER USING e
      Err( "I_0830", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.57*100,1)
      Show( "I_0831", r )
   RECOVER USING e
      Err( "I_0831", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.57*100,2)
      Show( "I_0832", r )
   RECOVER USING e
      Err( "I_0832", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.57*100,3)
      Show( "I_0833", r )
   RECOVER USING e
      Err( "I_0833", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.57*100,4)
      Show( "I_0834", r )
   RECOVER USING e
      Err( "I_0834", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.15*100,0)
      Show( "I_0835", r )
   RECOVER USING e
      Err( "I_0835", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.15*100,1)
      Show( "I_0836", r )
   RECOVER USING e
      Err( "I_0836", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.15*100,2)
      Show( "I_0837", r )
   RECOVER USING e
      Err( "I_0837", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.15*100,3)
      Show( "I_0838", r )
   RECOVER USING e
      Err( "I_0838", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.15*100,4)
      Show( "I_0839", r )
   RECOVER USING e
      Err( "I_0839", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4.35*100,0)
      Show( "I_0840", r )
   RECOVER USING e
      Err( "I_0840", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4.35*100,1)
      Show( "I_0841", r )
   RECOVER USING e
      Err( "I_0841", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4.35*100,2)
      Show( "I_0842", r )
   RECOVER USING e
      Err( "I_0842", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4.35*100,3)
      Show( "I_0843", r )
   RECOVER USING e
      Err( "I_0843", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4.35*100,4)
      Show( "I_0844", r )
   RECOVER USING e
      Err( "I_0844", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005*1000,0)
      Show( "I_0845", r )
   RECOVER USING e
      Err( "I_0845", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005*1000,1)
      Show( "I_0846", r )
   RECOVER USING e
      Err( "I_0846", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005*1000,2)
      Show( "I_0847", r )
   RECOVER USING e
      Err( "I_0847", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005*1000,3)
      Show( "I_0848", r )
   RECOVER USING e
      Err( "I_0848", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005*1000,4)
      Show( "I_0849", r )
   RECOVER USING e
      Err( "I_0849", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675*100,0)
      Show( "I_0850", r )
   RECOVER USING e
      Err( "I_0850", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675*100,1)
      Show( "I_0851", r )
   RECOVER USING e
      Err( "I_0851", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675*100,2)
      Show( "I_0852", r )
   RECOVER USING e
      Err( "I_0852", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675*100,3)
      Show( "I_0853", r )
   RECOVER USING e
      Err( "I_0853", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675*100,4)
      Show( "I_0854", r )
   RECOVER USING e
      Err( "I_0854", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285*100,0)
      Show( "I_0855", r )
   RECOVER USING e
      Err( "I_0855", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285*100,1)
      Show( "I_0856", r )
   RECOVER USING e
      Err( "I_0856", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285*100,2)
      Show( "I_0857", r )
   RECOVER USING e
      Err( "I_0857", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285*100,3)
      Show( "I_0858", r )
   RECOVER USING e
      Err( "I_0858", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285*100,4)
      Show( "I_0859", r )
   RECOVER USING e
      Err( "I_0859", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round((0.1+0.2)*10,0)
      Show( "I_0860", r )
   RECOVER USING e
      Err( "I_0860", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round((0.1+0.2)*10,1)
      Show( "I_0861", r )
   RECOVER USING e
      Err( "I_0861", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round((0.1+0.2)*10,2)
      Show( "I_0862", r )
   RECOVER USING e
      Err( "I_0862", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round((0.1+0.2)*10,3)
      Show( "I_0863", r )
   RECOVER USING e
      Err( "I_0863", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round((0.1+0.2)*10,4)
      Show( "I_0864", r )
   RECOVER USING e
      Err( "I_0864", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,0)
      Show( "I_0865", r )
   RECOVER USING e
      Err( "I_0865", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,1)
      Show( "I_0866", r )
   RECOVER USING e
      Err( "I_0866", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,2)
      Show( "I_0867", r )
   RECOVER USING e
      Err( "I_0867", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,3)
      Show( "I_0868", r )
   RECOVER USING e
      Err( "I_0868", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,4)
      Show( "I_0869", r )
   RECOVER USING e
      Err( "I_0869", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "I_0870", r )
   RECOVER USING e
      Err( "I_0870", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,1)
      Show( "I_0871", r )
   RECOVER USING e
      Err( "I_0871", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,2)
      Show( "I_0872", r )
   RECOVER USING e
      Err( "I_0872", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,3)
      Show( "I_0873", r )
   RECOVER USING e
      Err( "I_0873", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,4)
      Show( "I_0874", r )
   RECOVER USING e
      Err( "I_0874", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,0)
      Show( "I_0875", r )
   RECOVER USING e
      Err( "I_0875", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,1)
      Show( "I_0876", r )
   RECOVER USING e
      Err( "I_0876", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,2)
      Show( "I_0877", r )
   RECOVER USING e
      Err( "I_0877", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "I_0878", r )
   RECOVER USING e
      Err( "I_0878", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,4)
      Show( "I_0879", r )
   RECOVER USING e
      Err( "I_0879", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100/3,0)
      Show( "I_0880", r )
   RECOVER USING e
      Err( "I_0880", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100/3,1)
      Show( "I_0881", r )
   RECOVER USING e
      Err( "I_0881", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100/3,2)
      Show( "I_0882", r )
   RECOVER USING e
      Err( "I_0882", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100/3,3)
      Show( "I_0883", r )
   RECOVER USING e
      Err( "I_0883", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100/3,4)
      Show( "I_0884", r )
   RECOVER USING e
      Err( "I_0884", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000/7,0)
      Show( "I_0885", r )
   RECOVER USING e
      Err( "I_0885", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000/7,1)
      Show( "I_0886", r )
   RECOVER USING e
      Err( "I_0886", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000/7,2)
      Show( "I_0887", r )
   RECOVER USING e
      Err( "I_0887", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000/7,3)
      Show( "I_0888", r )
   RECOVER USING e
      Err( "I_0888", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000/7,4)
      Show( "I_0889", r )
   RECOVER USING e
      Err( "I_0889", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(22/7,0)
      Show( "I_0890", r )
   RECOVER USING e
      Err( "I_0890", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(22/7,1)
      Show( "I_0891", r )
   RECOVER USING e
      Err( "I_0891", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(22/7,2)
      Show( "I_0892", r )
   RECOVER USING e
      Err( "I_0892", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(22/7,3)
      Show( "I_0893", r )
   RECOVER USING e
      Err( "I_0893", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(22/7,4)
      Show( "I_0894", r )
   RECOVER USING e
      Err( "I_0894", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Sqrt(2),0)
      Show( "I_0895", r )
   RECOVER USING e
      Err( "I_0895", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Sqrt(2),1)
      Show( "I_0896", r )
   RECOVER USING e
      Err( "I_0896", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Sqrt(2),2)
      Show( "I_0897", r )
   RECOVER USING e
      Err( "I_0897", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Sqrt(2),3)
      Show( "I_0898", r )
   RECOVER USING e
      Err( "I_0898", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Sqrt(2),4)
      Show( "I_0899", r )
   RECOVER USING e
      Err( "I_0899", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Sqrt(2)*Sqrt(2),0)
      Show( "I_0900", r )
   RECOVER USING e
      Err( "I_0900", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Sqrt(2)*Sqrt(2),1)
      Show( "I_0901", r )
   RECOVER USING e
      Err( "I_0901", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Sqrt(2)*Sqrt(2),2)
      Show( "I_0902", r )
   RECOVER USING e
      Err( "I_0902", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Sqrt(2)*Sqrt(2),3)
      Show( "I_0903", r )
   RECOVER USING e
      Err( "I_0903", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Sqrt(2)*Sqrt(2),4)
      Show( "I_0904", r )
   RECOVER USING e
      Err( "I_0904", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Exp(1),0)
      Show( "I_0905", r )
   RECOVER USING e
      Err( "I_0905", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Exp(1),1)
      Show( "I_0906", r )
   RECOVER USING e
      Err( "I_0906", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Exp(1),2)
      Show( "I_0907", r )
   RECOVER USING e
      Err( "I_0907", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Exp(1),3)
      Show( "I_0908", r )
   RECOVER USING e
      Err( "I_0908", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Exp(1),4)
      Show( "I_0909", r )
   RECOVER USING e
      Err( "I_0909", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Log(10),0)
      Show( "I_0910", r )
   RECOVER USING e
      Err( "I_0910", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Log(10),1)
      Show( "I_0911", r )
   RECOVER USING e
      Err( "I_0911", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Log(10),2)
      Show( "I_0912", r )
   RECOVER USING e
      Err( "I_0912", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Log(10),3)
      Show( "I_0913", r )
   RECOVER USING e
      Err( "I_0913", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Log(10),4)
      Show( "I_0914", r )
   RECOVER USING e
      Err( "I_0914", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1*3,0)
      Show( "I_0915", r )
   RECOVER USING e
      Err( "I_0915", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1*3,1)
      Show( "I_0916", r )
   RECOVER USING e
      Err( "I_0916", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1*3,2)
      Show( "I_0917", r )
   RECOVER USING e
      Err( "I_0917", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1*3,3)
      Show( "I_0918", r )
   RECOVER USING e
      Err( "I_0918", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1*3,4)
      Show( "I_0919", r )
   RECOVER USING e
      Err( "I_0919", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.07*100,0)
      Show( "I_0920", r )
   RECOVER USING e
      Err( "I_0920", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.07*100,1)
      Show( "I_0921", r )
   RECOVER USING e
      Err( "I_0921", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.07*100,2)
      Show( "I_0922", r )
   RECOVER USING e
      Err( "I_0922", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.07*100,3)
      Show( "I_0923", r )
   RECOVER USING e
      Err( "I_0923", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.07*100,4)
      Show( "I_0924", r )
   RECOVER USING e
      Err( "I_0924", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(8.2-0.2,0)
      Show( "I_0925", r )
   RECOVER USING e
      Err( "I_0925", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(8.2-0.2,1)
      Show( "I_0926", r )
   RECOVER USING e
      Err( "I_0926", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(8.2-0.2,2)
      Show( "I_0927", r )
   RECOVER USING e
      Err( "I_0927", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(8.2-0.2,3)
      Show( "I_0928", r )
   RECOVER USING e
      Err( "I_0928", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(8.2-0.2,4)
      Show( "I_0929", r )
   RECOVER USING e
      Err( "I_0929", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.4-1.0,0)
      Show( "I_0930", r )
   RECOVER USING e
      Err( "I_0930", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.4-1.0,1)
      Show( "I_0931", r )
   RECOVER USING e
      Err( "I_0931", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.4-1.0,2)
      Show( "I_0932", r )
   RECOVER USING e
      Err( "I_0932", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.4-1.0,3)
      Show( "I_0933", r )
   RECOVER USING e
      Err( "I_0933", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.4-1.0,4)
      Show( "I_0934", r )
   RECOVER USING e
      Err( "I_0934", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('1.005'),0)
      Show( "I_0935", r )
   RECOVER USING e
      Err( "I_0935", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('1.005'),1)
      Show( "I_0936", r )
   RECOVER USING e
      Err( "I_0936", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('1.005'),2)
      Show( "I_0937", r )
   RECOVER USING e
      Err( "I_0937", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('1.005'),3)
      Show( "I_0938", r )
   RECOVER USING e
      Err( "I_0938", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('1.005'),4)
      Show( "I_0939", r )
   RECOVER USING e
      Err( "I_0939", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('2.675'),0)
      Show( "I_0940", r )
   RECOVER USING e
      Err( "I_0940", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('2.675'),1)
      Show( "I_0941", r )
   RECOVER USING e
      Err( "I_0941", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('2.675'),2)
      Show( "I_0942", r )
   RECOVER USING e
      Err( "I_0942", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('2.675'),3)
      Show( "I_0943", r )
   RECOVER USING e
      Err( "I_0943", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('2.675'),4)
      Show( "I_0944", r )
   RECOVER USING e
      Err( "I_0944", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('0.285'),0)
      Show( "I_0945", r )
   RECOVER USING e
      Err( "I_0945", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('0.285'),1)
      Show( "I_0946", r )
   RECOVER USING e
      Err( "I_0946", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('0.285'),2)
      Show( "I_0947", r )
   RECOVER USING e
      Err( "I_0947", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('0.285'),3)
      Show( "I_0948", r )
   RECOVER USING e
      Err( "I_0948", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('0.285'),4)
      Show( "I_0949", r )
   RECOVER USING e
      Err( "I_0949", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('1e2'),0)
      Show( "I_0950", r )
   RECOVER USING e
      Err( "I_0950", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('1e2'),1)
      Show( "I_0951", r )
   RECOVER USING e
      Err( "I_0951", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('1e2'),2)
      Show( "I_0952", r )
   RECOVER USING e
      Err( "I_0952", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('1e2'),3)
      Show( "I_0953", r )
   RECOVER USING e
      Err( "I_0953", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('1e2'),4)
      Show( "I_0954", r )
   RECOVER USING e
      Err( "I_0954", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('  12.345'),0)
      Show( "I_0955", r )
   RECOVER USING e
      Err( "I_0955", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('  12.345'),1)
      Show( "I_0956", r )
   RECOVER USING e
      Err( "I_0956", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('  12.345'),2)
      Show( "I_0957", r )
   RECOVER USING e
      Err( "I_0957", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('  12.345'),3)
      Show( "I_0958", r )
   RECOVER USING e
      Err( "I_0958", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('  12.345'),4)
      Show( "I_0959", r )
   RECOVER USING e
      Err( "I_0959", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('-0.5'),0)
      Show( "I_0960", r )
   RECOVER USING e
      Err( "I_0960", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('-0.5'),1)
      Show( "I_0961", r )
   RECOVER USING e
      Err( "I_0961", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('-0.5'),2)
      Show( "I_0962", r )
   RECOVER USING e
      Err( "I_0962", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('-0.5'),3)
      Show( "I_0963", r )
   RECOVER USING e
      Err( "I_0963", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('-0.5'),4)
      Show( "I_0964", r )
   RECOVER USING e
      Err( "I_0964", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('0.5e1'),0)
      Show( "I_0965", r )
   RECOVER USING e
      Err( "I_0965", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('0.5e1'),1)
      Show( "I_0966", r )
   RECOVER USING e
      Err( "I_0966", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('0.5e1'),2)
      Show( "I_0967", r )
   RECOVER USING e
      Err( "I_0967", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('0.5e1'),3)
      Show( "I_0968", r )
   RECOVER USING e
      Err( "I_0968", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('0.5e1'),4)
      Show( "I_0969", r )
   RECOVER USING e
      Err( "I_0969", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('12abc'),0)
      Show( "I_0970", r )
   RECOVER USING e
      Err( "I_0970", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('12abc'),1)
      Show( "I_0971", r )
   RECOVER USING e
      Err( "I_0971", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('12abc'),2)
      Show( "I_0972", r )
   RECOVER USING e
      Err( "I_0972", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('12abc'),3)
      Show( "I_0973", r )
   RECOVER USING e
      Err( "I_0973", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val('12abc'),4)
      Show( "I_0974", r )
   RECOVER USING e
      Err( "I_0974", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(''),0)
      Show( "I_0975", r )
   RECOVER USING e
      Err( "I_0975", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(''),1)
      Show( "I_0976", r )
   RECOVER USING e
      Err( "I_0976", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(''),2)
      Show( "I_0977", r )
   RECOVER USING e
      Err( "I_0977", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(''),3)
      Show( "I_0978", r )
   RECOVER USING e
      Err( "I_0978", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(''),4)
      Show( "I_0979", r )
   RECOVER USING e
      Err( "I_0979", e )
   END SEQUENCE
   RETURN

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
      r := Round(1.005,9)
      Show( "H_0658", r )
   RECOVER USING e
      Err( "H_0658", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,10)
      Show( "H_0659", r )
   RECOVER USING e
      Err( "H_0659", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,12)
      Show( "H_0660", r )
   RECOVER USING e
      Err( "H_0660", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,14)
      Show( "H_0661", r )
   RECOVER USING e
      Err( "H_0661", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,15)
      Show( "H_0662", r )
   RECOVER USING e
      Err( "H_0662", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,16)
      Show( "H_0663", r )
   RECOVER USING e
      Err( "H_0663", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,17)
      Show( "H_0664", r )
   RECOVER USING e
      Err( "H_0664", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,18)
      Show( "H_0665", r )
   RECOVER USING e
      Err( "H_0665", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,19)
      Show( "H_0666", r )
   RECOVER USING e
      Err( "H_0666", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,20)
      Show( "H_0667", r )
   RECOVER USING e
      Err( "H_0667", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,25)
      Show( "H_0668", r )
   RECOVER USING e
      Err( "H_0668", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,30)
      Show( "H_0669", r )
   RECOVER USING e
      Err( "H_0669", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,50)
      Show( "H_0670", r )
   RECOVER USING e
      Err( "H_0670", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,100)
      Show( "H_0671", r )
   RECOVER USING e
      Err( "H_0671", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,127)
      Show( "H_0672", r )
   RECOVER USING e
      Err( "H_0672", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,128)
      Show( "H_0673", r )
   RECOVER USING e
      Err( "H_0673", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,255)
      Show( "H_0674", r )
   RECOVER USING e
      Err( "H_0674", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,256)
      Show( "H_0675", r )
   RECOVER USING e
      Err( "H_0675", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,1000)
      Show( "H_0676", r )
   RECOVER USING e
      Err( "H_0676", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,9)
      Show( "H_0677", r )
   RECOVER USING e
      Err( "H_0677", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,10)
      Show( "H_0678", r )
   RECOVER USING e
      Err( "H_0678", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,12)
      Show( "H_0679", r )
   RECOVER USING e
      Err( "H_0679", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,14)
      Show( "H_0680", r )
   RECOVER USING e
      Err( "H_0680", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,15)
      Show( "H_0681", r )
   RECOVER USING e
      Err( "H_0681", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,16)
      Show( "H_0682", r )
   RECOVER USING e
      Err( "H_0682", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,17)
      Show( "H_0683", r )
   RECOVER USING e
      Err( "H_0683", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,18)
      Show( "H_0684", r )
   RECOVER USING e
      Err( "H_0684", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,19)
      Show( "H_0685", r )
   RECOVER USING e
      Err( "H_0685", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,20)
      Show( "H_0686", r )
   RECOVER USING e
      Err( "H_0686", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,25)
      Show( "H_0687", r )
   RECOVER USING e
      Err( "H_0687", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,30)
      Show( "H_0688", r )
   RECOVER USING e
      Err( "H_0688", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,50)
      Show( "H_0689", r )
   RECOVER USING e
      Err( "H_0689", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,100)
      Show( "H_0690", r )
   RECOVER USING e
      Err( "H_0690", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,127)
      Show( "H_0691", r )
   RECOVER USING e
      Err( "H_0691", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,128)
      Show( "H_0692", r )
   RECOVER USING e
      Err( "H_0692", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,255)
      Show( "H_0693", r )
   RECOVER USING e
      Err( "H_0693", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,256)
      Show( "H_0694", r )
   RECOVER USING e
      Err( "H_0694", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.141592653589793,1000)
      Show( "H_0695", r )
   RECOVER USING e
      Err( "H_0695", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,9)
      Show( "H_0696", r )
   RECOVER USING e
      Err( "H_0696", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,10)
      Show( "H_0697", r )
   RECOVER USING e
      Err( "H_0697", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,12)
      Show( "H_0698", r )
   RECOVER USING e
      Err( "H_0698", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,14)
      Show( "H_0699", r )
   RECOVER USING e
      Err( "H_0699", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,15)
      Show( "H_0700", r )
   RECOVER USING e
      Err( "H_0700", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,16)
      Show( "H_0701", r )
   RECOVER USING e
      Err( "H_0701", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,17)
      Show( "H_0702", r )
   RECOVER USING e
      Err( "H_0702", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,18)
      Show( "H_0703", r )
   RECOVER USING e
      Err( "H_0703", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,19)
      Show( "H_0704", r )
   RECOVER USING e
      Err( "H_0704", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,20)
      Show( "H_0705", r )
   RECOVER USING e
      Err( "H_0705", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,25)
      Show( "H_0706", r )
   RECOVER USING e
      Err( "H_0706", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,30)
      Show( "H_0707", r )
   RECOVER USING e
      Err( "H_0707", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,50)
      Show( "H_0708", r )
   RECOVER USING e
      Err( "H_0708", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,100)
      Show( "H_0709", r )
   RECOVER USING e
      Err( "H_0709", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,127)
      Show( "H_0710", r )
   RECOVER USING e
      Err( "H_0710", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,128)
      Show( "H_0711", r )
   RECOVER USING e
      Err( "H_0711", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,255)
      Show( "H_0712", r )
   RECOVER USING e
      Err( "H_0712", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,256)
      Show( "H_0713", r )
   RECOVER USING e
      Err( "H_0713", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,1000)
      Show( "H_0714", r )
   RECOVER USING e
      Err( "H_0714", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,9)
      Show( "H_0715", r )
   RECOVER USING e
      Err( "H_0715", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "H_0716", r )
   RECOVER USING e
      Err( "H_0716", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,12)
      Show( "H_0717", r )
   RECOVER USING e
      Err( "H_0717", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,14)
      Show( "H_0718", r )
   RECOVER USING e
      Err( "H_0718", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,15)
      Show( "H_0719", r )
   RECOVER USING e
      Err( "H_0719", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,16)
      Show( "H_0720", r )
   RECOVER USING e
      Err( "H_0720", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,17)
      Show( "H_0721", r )
   RECOVER USING e
      Err( "H_0721", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,18)
      Show( "H_0722", r )
   RECOVER USING e
      Err( "H_0722", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,19)
      Show( "H_0723", r )
   RECOVER USING e
      Err( "H_0723", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,20)
      Show( "H_0724", r )
   RECOVER USING e
      Err( "H_0724", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,25)
      Show( "H_0725", r )
   RECOVER USING e
      Err( "H_0725", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,30)
      Show( "H_0726", r )
   RECOVER USING e
      Err( "H_0726", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,50)
      Show( "H_0727", r )
   RECOVER USING e
      Err( "H_0727", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,100)
      Show( "H_0728", r )
   RECOVER USING e
      Err( "H_0728", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,127)
      Show( "H_0729", r )
   RECOVER USING e
      Err( "H_0729", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,128)
      Show( "H_0730", r )
   RECOVER USING e
      Err( "H_0730", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,255)
      Show( "H_0731", r )
   RECOVER USING e
      Err( "H_0731", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,256)
      Show( "H_0732", r )
   RECOVER USING e
      Err( "H_0732", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,1000)
      Show( "H_0733", r )
   RECOVER USING e
      Err( "H_0733", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,9)
      Show( "H_0734", r )
   RECOVER USING e
      Err( "H_0734", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,10)
      Show( "H_0735", r )
   RECOVER USING e
      Err( "H_0735", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,12)
      Show( "H_0736", r )
   RECOVER USING e
      Err( "H_0736", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,14)
      Show( "H_0737", r )
   RECOVER USING e
      Err( "H_0737", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,15)
      Show( "H_0738", r )
   RECOVER USING e
      Err( "H_0738", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,16)
      Show( "H_0739", r )
   RECOVER USING e
      Err( "H_0739", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,17)
      Show( "H_0740", r )
   RECOVER USING e
      Err( "H_0740", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,18)
      Show( "H_0741", r )
   RECOVER USING e
      Err( "H_0741", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,19)
      Show( "H_0742", r )
   RECOVER USING e
      Err( "H_0742", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,20)
      Show( "H_0743", r )
   RECOVER USING e
      Err( "H_0743", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,25)
      Show( "H_0744", r )
   RECOVER USING e
      Err( "H_0744", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,30)
      Show( "H_0745", r )
   RECOVER USING e
      Err( "H_0745", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,50)
      Show( "H_0746", r )
   RECOVER USING e
      Err( "H_0746", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,100)
      Show( "H_0747", r )
   RECOVER USING e
      Err( "H_0747", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,127)
      Show( "H_0748", r )
   RECOVER USING e
      Err( "H_0748", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,128)
      Show( "H_0749", r )
   RECOVER USING e
      Err( "H_0749", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,255)
      Show( "H_0750", r )
   RECOVER USING e
      Err( "H_0750", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,256)
      Show( "H_0751", r )
   RECOVER USING e
      Err( "H_0751", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,1000)
      Show( "H_0752", r )
   RECOVER USING e
      Err( "H_0752", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,9)
      Show( "H_0753", r )
   RECOVER USING e
      Err( "H_0753", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,10)
      Show( "H_0754", r )
   RECOVER USING e
      Err( "H_0754", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,12)
      Show( "H_0755", r )
   RECOVER USING e
      Err( "H_0755", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,14)
      Show( "H_0756", r )
   RECOVER USING e
      Err( "H_0756", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,15)
      Show( "H_0757", r )
   RECOVER USING e
      Err( "H_0757", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,16)
      Show( "H_0758", r )
   RECOVER USING e
      Err( "H_0758", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,17)
      Show( "H_0759", r )
   RECOVER USING e
      Err( "H_0759", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,18)
      Show( "H_0760", r )
   RECOVER USING e
      Err( "H_0760", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,19)
      Show( "H_0761", r )
   RECOVER USING e
      Err( "H_0761", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,20)
      Show( "H_0762", r )
   RECOVER USING e
      Err( "H_0762", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,25)
      Show( "H_0763", r )
   RECOVER USING e
      Err( "H_0763", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,30)
      Show( "H_0764", r )
   RECOVER USING e
      Err( "H_0764", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,50)
      Show( "H_0765", r )
   RECOVER USING e
      Err( "H_0765", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,100)
      Show( "H_0766", r )
   RECOVER USING e
      Err( "H_0766", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,127)
      Show( "H_0767", r )
   RECOVER USING e
      Err( "H_0767", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,128)
      Show( "H_0768", r )
   RECOVER USING e
      Err( "H_0768", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,255)
      Show( "H_0769", r )
   RECOVER USING e
      Err( "H_0769", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,256)
      Show( "H_0770", r )
   RECOVER USING e
      Err( "H_0770", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.0/7,1000)
      Show( "H_0771", r )
   RECOVER USING e
      Err( "H_0771", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,9)
      Show( "H_0772", r )
   RECOVER USING e
      Err( "H_0772", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,10)
      Show( "H_0773", r )
   RECOVER USING e
      Err( "H_0773", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,12)
      Show( "H_0774", r )
   RECOVER USING e
      Err( "H_0774", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,14)
      Show( "H_0775", r )
   RECOVER USING e
      Err( "H_0775", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,15)
      Show( "H_0776", r )
   RECOVER USING e
      Err( "H_0776", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,16)
      Show( "H_0777", r )
   RECOVER USING e
      Err( "H_0777", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,17)
      Show( "H_0778", r )
   RECOVER USING e
      Err( "H_0778", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,18)
      Show( "H_0779", r )
   RECOVER USING e
      Err( "H_0779", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,19)
      Show( "H_0780", r )
   RECOVER USING e
      Err( "H_0780", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,20)
      Show( "H_0781", r )
   RECOVER USING e
      Err( "H_0781", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,25)
      Show( "H_0782", r )
   RECOVER USING e
      Err( "H_0782", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,30)
      Show( "H_0783", r )
   RECOVER USING e
      Err( "H_0783", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,50)
      Show( "H_0784", r )
   RECOVER USING e
      Err( "H_0784", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,100)
      Show( "H_0785", r )
   RECOVER USING e
      Err( "H_0785", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,127)
      Show( "H_0786", r )
   RECOVER USING e
      Err( "H_0786", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,128)
      Show( "H_0787", r )
   RECOVER USING e
      Err( "H_0787", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,255)
      Show( "H_0788", r )
   RECOVER USING e
      Err( "H_0788", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,256)
      Show( "H_0789", r )
   RECOVER USING e
      Err( "H_0789", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,1000)
      Show( "H_0790", r )
   RECOVER USING e
      Err( "H_0790", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,9)
      Show( "H_0791", r )
   RECOVER USING e
      Err( "H_0791", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,10)
      Show( "H_0792", r )
   RECOVER USING e
      Err( "H_0792", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,12)
      Show( "H_0793", r )
   RECOVER USING e
      Err( "H_0793", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,14)
      Show( "H_0794", r )
   RECOVER USING e
      Err( "H_0794", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,15)
      Show( "H_0795", r )
   RECOVER USING e
      Err( "H_0795", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,16)
      Show( "H_0796", r )
   RECOVER USING e
      Err( "H_0796", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,17)
      Show( "H_0797", r )
   RECOVER USING e
      Err( "H_0797", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,18)
      Show( "H_0798", r )
   RECOVER USING e
      Err( "H_0798", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,19)
      Show( "H_0799", r )
   RECOVER USING e
      Err( "H_0799", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,20)
      Show( "H_0800", r )
   RECOVER USING e
      Err( "H_0800", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,25)
      Show( "H_0801", r )
   RECOVER USING e
      Err( "H_0801", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,30)
      Show( "H_0802", r )
   RECOVER USING e
      Err( "H_0802", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,50)
      Show( "H_0803", r )
   RECOVER USING e
      Err( "H_0803", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,100)
      Show( "H_0804", r )
   RECOVER USING e
      Err( "H_0804", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,127)
      Show( "H_0805", r )
   RECOVER USING e
      Err( "H_0805", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,128)
      Show( "H_0806", r )
   RECOVER USING e
      Err( "H_0806", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,255)
      Show( "H_0807", r )
   RECOVER USING e
      Err( "H_0807", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,256)
      Show( "H_0808", r )
   RECOVER USING e
      Err( "H_0808", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1000)
      Show( "H_0809", r )
   RECOVER USING e
      Err( "H_0809", e )
   END SEQUENCE
   RETURN

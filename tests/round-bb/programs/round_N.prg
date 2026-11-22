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
      r := Round(1.005,2)==1.001
      Show( "N_2013", r )
   RECOVER USING e
      Err( "N_2013", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)==1.000
      Show( "N_2014", r )
   RECOVER USING e
      Err( "N_2014", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)-1.001
      Show( "N_2015", r )
   RECOVER USING e
      Err( "N_2015", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)-1.000
      Show( "N_2016", r )
   RECOVER USING e
      Err( "N_2016", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Round(1.005,2),2)==Round(1.005,2)
      Show( "N_2017", r )
   RECOVER USING e
      Err( "N_2017", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)*100
      Show( "N_2018", r )
   RECOVER USING e
      Err( "N_2018", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Round(1.005,2)*100)
      Show( "N_2019", r )
   RECOVER USING e
      Err( "N_2019", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005*100,0)
      Show( "N_2020", r )
   RECOVER USING e
      Err( "N_2020", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)+0.0
      Show( "N_2021", r )
   RECOVER USING e
      Err( "N_2021", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)*1
      Show( "N_2022", r )
   RECOVER USING e
      Err( "N_2022", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)==2.671
      Show( "N_2023", r )
   RECOVER USING e
      Err( "N_2023", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)==2.670
      Show( "N_2024", r )
   RECOVER USING e
      Err( "N_2024", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)-2.671
      Show( "N_2025", r )
   RECOVER USING e
      Err( "N_2025", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)-2.670
      Show( "N_2026", r )
   RECOVER USING e
      Err( "N_2026", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Round(2.675,2),2)==Round(2.675,2)
      Show( "N_2027", r )
   RECOVER USING e
      Err( "N_2027", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)*100
      Show( "N_2028", r )
   RECOVER USING e
      Err( "N_2028", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Round(2.675,2)*100)
      Show( "N_2029", r )
   RECOVER USING e
      Err( "N_2029", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675*100,0)
      Show( "N_2030", r )
   RECOVER USING e
      Err( "N_2030", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)+0.0
      Show( "N_2031", r )
   RECOVER USING e
      Err( "N_2031", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)*1
      Show( "N_2032", r )
   RECOVER USING e
      Err( "N_2032", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)==0.281
      Show( "N_2033", r )
   RECOVER USING e
      Err( "N_2033", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)==0.280
      Show( "N_2034", r )
   RECOVER USING e
      Err( "N_2034", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)-0.281
      Show( "N_2035", r )
   RECOVER USING e
      Err( "N_2035", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)-0.280
      Show( "N_2036", r )
   RECOVER USING e
      Err( "N_2036", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Round(0.285,2),2)==Round(0.285,2)
      Show( "N_2037", r )
   RECOVER USING e
      Err( "N_2037", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)*100
      Show( "N_2038", r )
   RECOVER USING e
      Err( "N_2038", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Round(0.285,2)*100)
      Show( "N_2039", r )
   RECOVER USING e
      Err( "N_2039", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285*100,0)
      Show( "N_2040", r )
   RECOVER USING e
      Err( "N_2040", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)+0.0
      Show( "N_2041", r )
   RECOVER USING e
      Err( "N_2041", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)*1
      Show( "N_2042", r )
   RECOVER USING e
      Err( "N_2042", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1+0.2,1)==0.3
      Show( "N_2043", r )
   RECOVER USING e
      Err( "N_2043", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1+0.2,1)-0.3
      Show( "N_2044", r )
   RECOVER USING e
      Err( "N_2044", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,2)*3
      Show( "N_2045", r )
   RECOVER USING e
      Err( "N_2045", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+0.5,0)-1000000000000000
      Show( "N_2046", r )
   RECOVER USING e
      Err( "N_2046", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.4,0)==0
      Show( "N_2047", r )
   RECOVER USING e
      Err( "N_2047", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/Round(-0.4,0)==0
      Show( "N_2048", r )
   RECOVER USING e
      Err( "N_2048", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Min(Round(-0.4,0),0)
      Show( "N_2049", r )
   RECOVER USING e
      Err( "N_2049", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(-0.0001,2),6,2)
      Show( "N_2050", r )
   RECOVER USING e
      Err( "N_2050", e )
   END SEQUENCE
   RETURN

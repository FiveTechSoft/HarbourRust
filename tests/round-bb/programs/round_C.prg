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
      r := Round(0.005,2)
      Show( "C_0072", r )
   RECOVER USING e
      Err( "C_0072", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.015,2)
      Show( "C_0073", r )
   RECOVER USING e
      Err( "C_0073", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.025,2)
      Show( "C_0074", r )
   RECOVER USING e
      Err( "C_0074", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.035,2)
      Show( "C_0075", r )
   RECOVER USING e
      Err( "C_0075", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.045,2)
      Show( "C_0076", r )
   RECOVER USING e
      Err( "C_0076", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.055,2)
      Show( "C_0077", r )
   RECOVER USING e
      Err( "C_0077", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.065,2)
      Show( "C_0078", r )
   RECOVER USING e
      Err( "C_0078", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.075,2)
      Show( "C_0079", r )
   RECOVER USING e
      Err( "C_0079", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.085,2)
      Show( "C_0080", r )
   RECOVER USING e
      Err( "C_0080", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.095,2)
      Show( "C_0081", r )
   RECOVER USING e
      Err( "C_0081", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.105,2)
      Show( "C_0082", r )
   RECOVER USING e
      Err( "C_0082", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.115,2)
      Show( "C_0083", r )
   RECOVER USING e
      Err( "C_0083", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.125,2)
      Show( "C_0084", r )
   RECOVER USING e
      Err( "C_0084", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.135,2)
      Show( "C_0085", r )
   RECOVER USING e
      Err( "C_0085", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.145,2)
      Show( "C_0086", r )
   RECOVER USING e
      Err( "C_0086", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.155,2)
      Show( "C_0087", r )
   RECOVER USING e
      Err( "C_0087", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.165,2)
      Show( "C_0088", r )
   RECOVER USING e
      Err( "C_0088", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.175,2)
      Show( "C_0089", r )
   RECOVER USING e
      Err( "C_0089", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.185,2)
      Show( "C_0090", r )
   RECOVER USING e
      Err( "C_0090", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.195,2)
      Show( "C_0091", r )
   RECOVER USING e
      Err( "C_0091", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.205,2)
      Show( "C_0092", r )
   RECOVER USING e
      Err( "C_0092", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.215,2)
      Show( "C_0093", r )
   RECOVER USING e
      Err( "C_0093", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.225,2)
      Show( "C_0094", r )
   RECOVER USING e
      Err( "C_0094", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.235,2)
      Show( "C_0095", r )
   RECOVER USING e
      Err( "C_0095", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.245,2)
      Show( "C_0096", r )
   RECOVER USING e
      Err( "C_0096", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.255,2)
      Show( "C_0097", r )
   RECOVER USING e
      Err( "C_0097", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.265,2)
      Show( "C_0098", r )
   RECOVER USING e
      Err( "C_0098", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.275,2)
      Show( "C_0099", r )
   RECOVER USING e
      Err( "C_0099", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "C_0100", r )
   RECOVER USING e
      Err( "C_0100", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.295,2)
      Show( "C_0101", r )
   RECOVER USING e
      Err( "C_0101", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.305,2)
      Show( "C_0102", r )
   RECOVER USING e
      Err( "C_0102", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.315,2)
      Show( "C_0103", r )
   RECOVER USING e
      Err( "C_0103", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.325,2)
      Show( "C_0104", r )
   RECOVER USING e
      Err( "C_0104", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.335,2)
      Show( "C_0105", r )
   RECOVER USING e
      Err( "C_0105", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.345,2)
      Show( "C_0106", r )
   RECOVER USING e
      Err( "C_0106", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.355,2)
      Show( "C_0107", r )
   RECOVER USING e
      Err( "C_0107", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.365,2)
      Show( "C_0108", r )
   RECOVER USING e
      Err( "C_0108", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.375,2)
      Show( "C_0109", r )
   RECOVER USING e
      Err( "C_0109", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.385,2)
      Show( "C_0110", r )
   RECOVER USING e
      Err( "C_0110", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.395,2)
      Show( "C_0111", r )
   RECOVER USING e
      Err( "C_0111", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.405,2)
      Show( "C_0112", r )
   RECOVER USING e
      Err( "C_0112", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.415,2)
      Show( "C_0113", r )
   RECOVER USING e
      Err( "C_0113", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.425,2)
      Show( "C_0114", r )
   RECOVER USING e
      Err( "C_0114", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.435,2)
      Show( "C_0115", r )
   RECOVER USING e
      Err( "C_0115", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.445,2)
      Show( "C_0116", r )
   RECOVER USING e
      Err( "C_0116", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.455,2)
      Show( "C_0117", r )
   RECOVER USING e
      Err( "C_0117", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.465,2)
      Show( "C_0118", r )
   RECOVER USING e
      Err( "C_0118", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.475,2)
      Show( "C_0119", r )
   RECOVER USING e
      Err( "C_0119", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.485,2)
      Show( "C_0120", r )
   RECOVER USING e
      Err( "C_0120", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.495,2)
      Show( "C_0121", r )
   RECOVER USING e
      Err( "C_0121", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.505,2)
      Show( "C_0122", r )
   RECOVER USING e
      Err( "C_0122", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.515,2)
      Show( "C_0123", r )
   RECOVER USING e
      Err( "C_0123", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.525,2)
      Show( "C_0124", r )
   RECOVER USING e
      Err( "C_0124", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.535,2)
      Show( "C_0125", r )
   RECOVER USING e
      Err( "C_0125", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.545,2)
      Show( "C_0126", r )
   RECOVER USING e
      Err( "C_0126", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.555,2)
      Show( "C_0127", r )
   RECOVER USING e
      Err( "C_0127", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.565,2)
      Show( "C_0128", r )
   RECOVER USING e
      Err( "C_0128", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.575,2)
      Show( "C_0129", r )
   RECOVER USING e
      Err( "C_0129", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.585,2)
      Show( "C_0130", r )
   RECOVER USING e
      Err( "C_0130", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.595,2)
      Show( "C_0131", r )
   RECOVER USING e
      Err( "C_0131", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.605,2)
      Show( "C_0132", r )
   RECOVER USING e
      Err( "C_0132", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.615,2)
      Show( "C_0133", r )
   RECOVER USING e
      Err( "C_0133", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.625,2)
      Show( "C_0134", r )
   RECOVER USING e
      Err( "C_0134", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.635,2)
      Show( "C_0135", r )
   RECOVER USING e
      Err( "C_0135", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.645,2)
      Show( "C_0136", r )
   RECOVER USING e
      Err( "C_0136", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.655,2)
      Show( "C_0137", r )
   RECOVER USING e
      Err( "C_0137", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.665,2)
      Show( "C_0138", r )
   RECOVER USING e
      Err( "C_0138", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.675,2)
      Show( "C_0139", r )
   RECOVER USING e
      Err( "C_0139", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.685,2)
      Show( "C_0140", r )
   RECOVER USING e
      Err( "C_0140", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.695,2)
      Show( "C_0141", r )
   RECOVER USING e
      Err( "C_0141", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.705,2)
      Show( "C_0142", r )
   RECOVER USING e
      Err( "C_0142", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.715,2)
      Show( "C_0143", r )
   RECOVER USING e
      Err( "C_0143", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.725,2)
      Show( "C_0144", r )
   RECOVER USING e
      Err( "C_0144", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.735,2)
      Show( "C_0145", r )
   RECOVER USING e
      Err( "C_0145", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.745,2)
      Show( "C_0146", r )
   RECOVER USING e
      Err( "C_0146", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.755,2)
      Show( "C_0147", r )
   RECOVER USING e
      Err( "C_0147", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.765,2)
      Show( "C_0148", r )
   RECOVER USING e
      Err( "C_0148", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.775,2)
      Show( "C_0149", r )
   RECOVER USING e
      Err( "C_0149", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.785,2)
      Show( "C_0150", r )
   RECOVER USING e
      Err( "C_0150", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.795,2)
      Show( "C_0151", r )
   RECOVER USING e
      Err( "C_0151", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.805,2)
      Show( "C_0152", r )
   RECOVER USING e
      Err( "C_0152", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.815,2)
      Show( "C_0153", r )
   RECOVER USING e
      Err( "C_0153", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.825,2)
      Show( "C_0154", r )
   RECOVER USING e
      Err( "C_0154", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.835,2)
      Show( "C_0155", r )
   RECOVER USING e
      Err( "C_0155", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.845,2)
      Show( "C_0156", r )
   RECOVER USING e
      Err( "C_0156", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.855,2)
      Show( "C_0157", r )
   RECOVER USING e
      Err( "C_0157", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.865,2)
      Show( "C_0158", r )
   RECOVER USING e
      Err( "C_0158", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.875,2)
      Show( "C_0159", r )
   RECOVER USING e
      Err( "C_0159", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.885,2)
      Show( "C_0160", r )
   RECOVER USING e
      Err( "C_0160", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.895,2)
      Show( "C_0161", r )
   RECOVER USING e
      Err( "C_0161", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.905,2)
      Show( "C_0162", r )
   RECOVER USING e
      Err( "C_0162", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.915,2)
      Show( "C_0163", r )
   RECOVER USING e
      Err( "C_0163", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.925,2)
      Show( "C_0164", r )
   RECOVER USING e
      Err( "C_0164", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.935,2)
      Show( "C_0165", r )
   RECOVER USING e
      Err( "C_0165", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.945,2)
      Show( "C_0166", r )
   RECOVER USING e
      Err( "C_0166", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.955,2)
      Show( "C_0167", r )
   RECOVER USING e
      Err( "C_0167", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.965,2)
      Show( "C_0168", r )
   RECOVER USING e
      Err( "C_0168", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.975,2)
      Show( "C_0169", r )
   RECOVER USING e
      Err( "C_0169", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.985,2)
      Show( "C_0170", r )
   RECOVER USING e
      Err( "C_0170", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.995,2)
      Show( "C_0171", r )
   RECOVER USING e
      Err( "C_0171", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.005,2)
      Show( "C_0172", r )
   RECOVER USING e
      Err( "C_0172", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "C_0173", r )
   RECOVER USING e
      Err( "C_0173", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-2.675,2)
      Show( "C_0174", r )
   RECOVER USING e
      Err( "C_0174", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "C_0175", r )
   RECOVER USING e
      Err( "C_0175", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.285,2)
      Show( "C_0176", r )
   RECOVER USING e
      Err( "C_0176", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "C_0177", r )
   RECOVER USING e
      Err( "C_0177", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.015,2)
      Show( "C_0178", r )
   RECOVER USING e
      Err( "C_0178", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.015,2)
      Show( "C_0179", r )
   RECOVER USING e
      Err( "C_0179", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.025,2)
      Show( "C_0180", r )
   RECOVER USING e
      Err( "C_0180", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.025,2)
      Show( "C_0181", r )
   RECOVER USING e
      Err( "C_0181", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.035,2)
      Show( "C_0182", r )
   RECOVER USING e
      Err( "C_0182", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.035,2)
      Show( "C_0183", r )
   RECOVER USING e
      Err( "C_0183", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.045,2)
      Show( "C_0184", r )
   RECOVER USING e
      Err( "C_0184", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.045,2)
      Show( "C_0185", r )
   RECOVER USING e
      Err( "C_0185", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-8.345,2)
      Show( "C_0186", r )
   RECOVER USING e
      Err( "C_0186", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(8.345,2)
      Show( "C_0187", r )
   RECOVER USING e
      Err( "C_0187", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-8.335,2)
      Show( "C_0188", r )
   RECOVER USING e
      Err( "C_0188", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(8.335,2)
      Show( "C_0189", r )
   RECOVER USING e
      Err( "C_0189", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-10.075,2)
      Show( "C_0190", r )
   RECOVER USING e
      Err( "C_0190", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10.075,2)
      Show( "C_0191", r )
   RECOVER USING e
      Err( "C_0191", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-100.005,2)
      Show( "C_0192", r )
   RECOVER USING e
      Err( "C_0192", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.005,2)
      Show( "C_0193", r )
   RECOVER USING e
      Err( "C_0193", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1000.005,2)
      Show( "C_0194", r )
   RECOVER USING e
      Err( "C_0194", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000.005,2)
      Show( "C_0195", r )
   RECOVER USING e
      Err( "C_0195", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.015,2)
      Show( "C_0196", r )
   RECOVER USING e
      Err( "C_0196", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.015,2)
      Show( "C_0197", r )
   RECOVER USING e
      Err( "C_0197", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.025,2)
      Show( "C_0198", r )
   RECOVER USING e
      Err( "C_0198", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.025,2)
      Show( "C_0199", r )
   RECOVER USING e
      Err( "C_0199", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.035,2)
      Show( "C_0200", r )
   RECOVER USING e
      Err( "C_0200", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.035,2)
      Show( "C_0201", r )
   RECOVER USING e
      Err( "C_0201", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.045,2)
      Show( "C_0202", r )
   RECOVER USING e
      Err( "C_0202", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.045,2)
      Show( "C_0203", r )
   RECOVER USING e
      Err( "C_0203", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.055,2)
      Show( "C_0204", r )
   RECOVER USING e
      Err( "C_0204", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.055,2)
      Show( "C_0205", r )
   RECOVER USING e
      Err( "C_0205", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.065,2)
      Show( "C_0206", r )
   RECOVER USING e
      Err( "C_0206", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.065,2)
      Show( "C_0207", r )
   RECOVER USING e
      Err( "C_0207", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.075,2)
      Show( "C_0208", r )
   RECOVER USING e
      Err( "C_0208", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.075,2)
      Show( "C_0209", r )
   RECOVER USING e
      Err( "C_0209", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.085,2)
      Show( "C_0210", r )
   RECOVER USING e
      Err( "C_0210", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.085,2)
      Show( "C_0211", r )
   RECOVER USING e
      Err( "C_0211", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.095,2)
      Show( "C_0212", r )
   RECOVER USING e
      Err( "C_0212", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.095,2)
      Show( "C_0213", r )
   RECOVER USING e
      Err( "C_0213", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.255,2)
      Show( "C_0214", r )
   RECOVER USING e
      Err( "C_0214", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.255,2)
      Show( "C_0215", r )
   RECOVER USING e
      Err( "C_0215", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.355,2)
      Show( "C_0216", r )
   RECOVER USING e
      Err( "C_0216", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.355,2)
      Show( "C_0217", r )
   RECOVER USING e
      Err( "C_0217", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-4.355,2)
      Show( "C_0218", r )
   RECOVER USING e
      Err( "C_0218", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4.355,2)
      Show( "C_0219", r )
   RECOVER USING e
      Err( "C_0219", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-5.015,2)
      Show( "C_0220", r )
   RECOVER USING e
      Err( "C_0220", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5.015,2)
      Show( "C_0221", r )
   RECOVER USING e
      Err( "C_0221", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-5.025,2)
      Show( "C_0222", r )
   RECOVER USING e
      Err( "C_0222", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5.025,2)
      Show( "C_0223", r )
   RECOVER USING e
      Err( "C_0223", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-5.035,2)
      Show( "C_0224", r )
   RECOVER USING e
      Err( "C_0224", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5.035,2)
      Show( "C_0225", r )
   RECOVER USING e
      Err( "C_0225", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-5.045,2)
      Show( "C_0226", r )
   RECOVER USING e
      Err( "C_0226", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5.045,2)
      Show( "C_0227", r )
   RECOVER USING e
      Err( "C_0227", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-9.995,2)
      Show( "C_0228", r )
   RECOVER USING e
      Err( "C_0228", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9.995,2)
      Show( "C_0229", r )
   RECOVER USING e
      Err( "C_0229", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-99.995,2)
      Show( "C_0230", r )
   RECOVER USING e
      Err( "C_0230", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99.995,2)
      Show( "C_0231", r )
   RECOVER USING e
      Err( "C_0231", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.994999,2)
      Show( "C_0232", r )
   RECOVER USING e
      Err( "C_0232", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.994999,2)
      Show( "C_0233", r )
   RECOVER USING e
      Err( "C_0233", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.995,2)
      Show( "C_0234", r )
   RECOVER USING e
      Err( "C_0234", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.995,2)
      Show( "C_0235", r )
   RECOVER USING e
      Err( "C_0235", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.9949999999,2)
      Show( "C_0236", r )
   RECOVER USING e
      Err( "C_0236", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.9949999999,2)
      Show( "C_0237", r )
   RECOVER USING e
      Err( "C_0237", e )
   END SEQUENCE
   RETURN

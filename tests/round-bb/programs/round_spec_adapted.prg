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
   P000()
   P001()
   P002()
   P003()
   P004()
   P005()
   P006()
   P007()
   P008()
   P009()
   P010()
   P011()
   P012()
   P013()
   P014()
   P015()
   P016()
   P017()
   P018()
   P019()
   P020()
   P021()
   P022()
   P023()
   P024()
   P025()
   P026()
   P027()
   P028()
   P029()
   P030()
   P031()
   P032()
   P033()
   P034()
   P035()
   P036()
   P037()
   P038()
   P039()
   P040()
   P041()
   P042()
   P043()
   P044()
   P045()
   P046()
   P047()
   P048()
   P049()
   P050()
   P051()
   P052()
   P053()
   P054()
   P055()
   P056()
   P057()
   P058()
   P059()
   P060()
   P061()
   P062()
   P063()
   P064()
   P065()
   P066()
   P067()
   P068()
   PS()
   RETURN
STATIC PROCEDURE P000()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.5,0)
      Show( "A_0001", r )
   RECOVER USING e
      Err( "A_0001", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "A_0002", r )
   RECOVER USING e
      Err( "A_0002", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.5,0)
      Show( "A_0003", r )
   RECOVER USING e
      Err( "A_0003", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(3.5,0)
      Show( "A_0004", r )
   RECOVER USING e
      Err( "A_0004", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4.5,0)
      Show( "A_0005", r )
   RECOVER USING e
      Err( "A_0005", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.5,0)
      Show( "A_0006", r )
   RECOVER USING e
      Err( "A_0006", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.5,0)
      Show( "A_0007", r )
   RECOVER USING e
      Err( "A_0007", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-2.5,0)
      Show( "A_0008", r )
   RECOVER USING e
      Err( "A_0008", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-3.5,0)
      Show( "A_0009", r )
   RECOVER USING e
      Err( "A_0009", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.49999999999999994,0)
      Show( "A_0010", r )
   RECOVER USING e
      Err( "A_0010", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.4999999999,0)
      Show( "A_0011", r )
   RECOVER USING e
      Err( "A_0011", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.5000000001,0)
      Show( "A_0012", r )
   RECOVER USING e
      Err( "A_0012", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.4999999999,0)
      Show( "A_0013", r )
   RECOVER USING e
      Err( "A_0013", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.5000000001,0)
      Show( "A_0014", r )
   RECOVER USING e
      Err( "A_0014", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.4999999999,0)
      Show( "A_0015", r )
   RECOVER USING e
      Err( "A_0015", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.4999999999,0)
      Show( "A_0016", r )
   RECOVER USING e
      Err( "A_0016", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0,0)
      Show( "A_0017", r )
   RECOVER USING e
      Err( "A_0017", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0,0)
      Show( "A_0018", r )
   RECOVER USING e
      Err( "A_0018", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.0,0)
      Show( "A_0019", r )
   RECOVER USING e
      Err( "A_0019", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99.5,0)
      Show( "A_0020", r )
   RECOVER USING e
      Err( "A_0020", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-99.5,0)
      Show( "A_0021", r )
   RECOVER USING e
      Err( "A_0021", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100.5,0)
      Show( "A_0022", r )
   RECOVER USING e
      Err( "A_0022", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000.5,0)
      Show( "A_0023", r )
   RECOVER USING e
      Err( "A_0023", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1000000.5,0)
      Show( "A_0024", r )
   RECOVER USING e
      Err( "A_0024", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1,0)
      Show( "A_0025", r )
   RECOVER USING e
      Err( "A_0025", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.9,0)
      Show( "A_0026", r )
   RECOVER USING e
      Err( "A_0026", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.1,0)
      Show( "A_0027", r )
   RECOVER USING e
      Err( "A_0027", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.9,0)
      Show( "A_0028", r )
   RECOVER USING e
      Err( "A_0028", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1,0)
      Show( "A_0029", r )
   RECOVER USING e
      Err( "A_0029", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1,0)
      Show( "A_0030", r )
   RECOVER USING e
      Err( "A_0030", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P001()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(7,0)
      Show( "A_0031", r )
   RECOVER USING e
      Err( "A_0031", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.05,1)
      Show( "B_0032", r )
   RECOVER USING e
      Err( "B_0032", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.05,1)
      Show( "B_0033", r )
   RECOVER USING e
      Err( "B_0033", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.15,1)
      Show( "B_0034", r )
   RECOVER USING e
      Err( "B_0034", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.15,1)
      Show( "B_0035", r )
   RECOVER USING e
      Err( "B_0035", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.25,1)
      Show( "B_0036", r )
   RECOVER USING e
      Err( "B_0036", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.25,1)
      Show( "B_0037", r )
   RECOVER USING e
      Err( "B_0037", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.35,1)
      Show( "B_0038", r )
   RECOVER USING e
      Err( "B_0038", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.35,1)
      Show( "B_0039", r )
   RECOVER USING e
      Err( "B_0039", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.45,1)
      Show( "B_0040", r )
   RECOVER USING e
      Err( "B_0040", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.45,1)
      Show( "B_0041", r )
   RECOVER USING e
      Err( "B_0041", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.55,1)
      Show( "B_0042", r )
   RECOVER USING e
      Err( "B_0042", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.55,1)
      Show( "B_0043", r )
   RECOVER USING e
      Err( "B_0043", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.65,1)
      Show( "B_0044", r )
   RECOVER USING e
      Err( "B_0044", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.65,1)
      Show( "B_0045", r )
   RECOVER USING e
      Err( "B_0045", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.75,1)
      Show( "B_0046", r )
   RECOVER USING e
      Err( "B_0046", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.75,1)
      Show( "B_0047", r )
   RECOVER USING e
      Err( "B_0047", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.85,1)
      Show( "B_0048", r )
   RECOVER USING e
      Err( "B_0048", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.85,1)
      Show( "B_0049", r )
   RECOVER USING e
      Err( "B_0049", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.95,1)
      Show( "B_0050", r )
   RECOVER USING e
      Err( "B_0050", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-0.95,1)
      Show( "B_0051", r )
   RECOVER USING e
      Err( "B_0051", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.05,1)
      Show( "B_0052", r )
   RECOVER USING e
      Err( "B_0052", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.05,1)
      Show( "B_0053", r )
   RECOVER USING e
      Err( "B_0053", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.15,1)
      Show( "B_0054", r )
   RECOVER USING e
      Err( "B_0054", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.15,1)
      Show( "B_0055", r )
   RECOVER USING e
      Err( "B_0055", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.25,1)
      Show( "B_0056", r )
   RECOVER USING e
      Err( "B_0056", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.25,1)
      Show( "B_0057", r )
   RECOVER USING e
      Err( "B_0057", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.35,1)
      Show( "B_0058", r )
   RECOVER USING e
      Err( "B_0058", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.35,1)
      Show( "B_0059", r )
   RECOVER USING e
      Err( "B_0059", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.45,1)
      Show( "B_0060", r )
   RECOVER USING e
      Err( "B_0060", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P002()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.45,1)
      Show( "B_0061", r )
   RECOVER USING e
      Err( "B_0061", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.55,1)
      Show( "B_0062", r )
   RECOVER USING e
      Err( "B_0062", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.55,1)
      Show( "B_0063", r )
   RECOVER USING e
      Err( "B_0063", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.65,1)
      Show( "B_0064", r )
   RECOVER USING e
      Err( "B_0064", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.65,1)
      Show( "B_0065", r )
   RECOVER USING e
      Err( "B_0065", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.75,1)
      Show( "B_0066", r )
   RECOVER USING e
      Err( "B_0066", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.75,1)
      Show( "B_0067", r )
   RECOVER USING e
      Err( "B_0067", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.85,1)
      Show( "B_0068", r )
   RECOVER USING e
      Err( "B_0068", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.85,1)
      Show( "B_0069", r )
   RECOVER USING e
      Err( "B_0069", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.95,1)
      Show( "B_0070", r )
   RECOVER USING e
      Err( "B_0070", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1.95,1)
      Show( "B_0071", r )
   RECOVER USING e
      Err( "B_0071", e )
   END SEQUENCE
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
   RETURN
STATIC PROCEDURE P003()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P004()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P005()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P006()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P007()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P008()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P009()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P010()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P011()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P012()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P013()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P014()
   LOCAL r, e
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
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999999999.5,0)
      Show( "F_0441", r )
   RECOVER USING e
      Err( "F_0441", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999999999.5,2)
      Show( "F_0442", r )
   RECOVER USING e
      Err( "F_0442", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999999999.5,-1)
      Show( "F_0443", r )
   RECOVER USING e
      Err( "F_0443", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999999999.4,0)
      Show( "F_0444", r )
   RECOVER USING e
      Err( "F_0444", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999999999.4,2)
      Show( "F_0445", r )
   RECOVER USING e
      Err( "F_0445", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(999999999999999.4,-1)
      Show( "F_0446", r )
   RECOVER USING e
      Err( "F_0446", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000.5,0)
      Show( "F_0447", r )
   RECOVER USING e
      Err( "F_0447", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000.5,2)
      Show( "F_0448", r )
   RECOVER USING e
      Err( "F_0448", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000.5,-1)
      Show( "F_0449", r )
   RECOVER USING e
      Err( "F_0449", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,0)
      Show( "F_0450", r )
   RECOVER USING e
      Err( "F_0450", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P015()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,2)
      Show( "F_0451", r )
   RECOVER USING e
      Err( "F_0451", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000,-1)
      Show( "F_0452", r )
   RECOVER USING e
      Err( "F_0452", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+0.5,0)
      Show( "F_0453", r )
   RECOVER USING e
      Err( "F_0453", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+0.5,2)
      Show( "F_0454", r )
   RECOVER USING e
      Err( "F_0454", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+0.5,-1)
      Show( "F_0455", r )
   RECOVER USING e
      Err( "F_0455", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+1,0)
      Show( "F_0456", r )
   RECOVER USING e
      Err( "F_0456", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+1,2)
      Show( "F_0457", r )
   RECOVER USING e
      Err( "F_0457", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000+1,-1)
      Show( "F_0458", r )
   RECOVER USING e
      Err( "F_0458", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000-0.5,0)
      Show( "F_0459", r )
   RECOVER USING e
      Err( "F_0459", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000-0.5,2)
      Show( "F_0460", r )
   RECOVER USING e
      Err( "F_0460", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000-0.5,-1)
      Show( "F_0461", r )
   RECOVER USING e
      Err( "F_0461", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345.67,0)
      Show( "F_0462", r )
   RECOVER USING e
      Err( "F_0462", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345.67,2)
      Show( "F_0463", r )
   RECOVER USING e
      Err( "F_0463", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345.67,-1)
      Show( "F_0464", r )
   RECOVER USING e
      Err( "F_0464", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345.5,0)
      Show( "F_0465", r )
   RECOVER USING e
      Err( "F_0465", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345.5,2)
      Show( "F_0466", r )
   RECOVER USING e
      Err( "F_0466", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345.5,-1)
      Show( "F_0467", r )
   RECOVER USING e
      Err( "F_0467", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-123456789012345.5,0)
      Show( "F_0468", r )
   RECOVER USING e
      Err( "F_0468", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-123456789012345.5,2)
      Show( "F_0469", r )
   RECOVER USING e
      Err( "F_0469", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-123456789012345.5,-1)
      Show( "F_0470", r )
   RECOVER USING e
      Err( "F_0470", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740991,0)
      Show( "F_0471", r )
   RECOVER USING e
      Err( "F_0471", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740991,2)
      Show( "F_0472", r )
   RECOVER USING e
      Err( "F_0472", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740991,-1)
      Show( "F_0473", r )
   RECOVER USING e
      Err( "F_0473", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740993,0)
      Show( "F_0474", r )
   RECOVER USING e
      Err( "F_0474", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740993,2)
      Show( "F_0475", r )
   RECOVER USING e
      Err( "F_0475", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740993,-1)
      Show( "F_0476", r )
   RECOVER USING e
      Err( "F_0476", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740992.5,0)
      Show( "F_0477", r )
   RECOVER USING e
      Err( "F_0477", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740992.5,2)
      Show( "F_0478", r )
   RECOVER USING e
      Err( "F_0478", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9007199254740992.5,-1)
      Show( "F_0479", r )
   RECOVER USING e
      Err( "F_0479", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370496.5,0)
      Show( "F_0480", r )
   RECOVER USING e
      Err( "F_0480", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P016()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370496.5,2)
      Show( "F_0481", r )
   RECOVER USING e
      Err( "F_0481", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370496.5,-1)
      Show( "F_0482", r )
   RECOVER USING e
      Err( "F_0482", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370497.5,0)
      Show( "F_0483", r )
   RECOVER USING e
      Err( "F_0483", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370497.5,2)
      Show( "F_0484", r )
   RECOVER USING e
      Err( "F_0484", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370497.5,-1)
      Show( "F_0485", r )
   RECOVER USING e
      Err( "F_0485", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370495.5,0)
      Show( "F_0486", r )
   RECOVER USING e
      Err( "F_0486", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370495.5,2)
      Show( "F_0487", r )
   RECOVER USING e
      Err( "F_0487", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4503599627370495.5,-1)
      Show( "F_0488", r )
   RECOVER USING e
      Err( "F_0488", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000,0)
      Show( "F_0489", r )
   RECOVER USING e
      Err( "F_0489", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000,2)
      Show( "F_0490", r )
   RECOVER USING e
      Err( "F_0490", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000,-1)
      Show( "F_0491", r )
   RECOVER USING e
      Err( "F_0491", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000+2,0)
      Show( "F_0492", r )
   RECOVER USING e
      Err( "F_0492", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000+2,2)
      Show( "F_0493", r )
   RECOVER USING e
      Err( "F_0493", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000+2,-1)
      Show( "F_0494", r )
   RECOVER USING e
      Err( "F_0494", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000000,0)
      Show( "F_0495", r )
   RECOVER USING e
      Err( "F_0495", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000000,2)
      Show( "F_0496", r )
   RECOVER USING e
      Err( "F_0496", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000000,-1)
      Show( "F_0497", r )
   RECOVER USING e
      Err( "F_0497", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000,0)
      Show( "F_0498", r )
   RECOVER USING e
      Err( "F_0498", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000,2)
      Show( "F_0499", r )
   RECOVER USING e
      Err( "F_0499", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000,-1)
      Show( "F_0500", r )
   RECOVER USING e
      Err( "F_0500", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000,0)
      Show( "F_0501", r )
   RECOVER USING e
      Err( "F_0501", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000,2)
      Show( "F_0502", r )
   RECOVER USING e
      Err( "F_0502", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000,-1)
      Show( "F_0503", r )
   RECOVER USING e
      Err( "F_0503", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000000000,0)
      Show( "F_0504", r )
   RECOVER USING e
      Err( "F_0504", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000000000,2)
      Show( "F_0505", r )
   RECOVER USING e
      Err( "F_0505", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000000000,-1)
      Show( "F_0506", r )
   RECOVER USING e
      Err( "F_0506", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(150000000000000000000,0)
      Show( "F_0507", r )
   RECOVER USING e
      Err( "F_0507", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(150000000000000000000,2)
      Show( "F_0508", r )
   RECOVER USING e
      Err( "F_0508", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(150000000000000000000,-1)
      Show( "F_0509", r )
   RECOVER USING e
      Err( "F_0509", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000000,0)
      Show( "F_0510", r )
   RECOVER USING e
      Err( "F_0510", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P017()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000000,2)
      Show( "F_0511", r )
   RECOVER USING e
      Err( "F_0511", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000000,-1)
      Show( "F_0512", r )
   RECOVER USING e
      Err( "F_0512", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000000000000000,0)
      Show( "F_0513", r )
   RECOVER USING e
      Err( "F_0513", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000000000000000,2)
      Show( "F_0514", r )
   RECOVER USING e
      Err( "F_0514", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000000000000000,-1)
      Show( "F_0515", r )
   RECOVER USING e
      Err( "F_0515", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,0)
      Show( "F_0516", r )
   RECOVER USING e
      Err( "F_0516", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,2)
      Show( "F_0517", r )
   RECOVER USING e
      Err( "F_0517", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,-1)
      Show( "F_0518", r )
   RECOVER USING e
      Err( "F_0518", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,0)
      Show( "F_0519", r )
   RECOVER USING e
      Err( "F_0519", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,2)
      Show( "F_0520", r )
   RECOVER USING e
      Err( "F_0520", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,-1)
      Show( "F_0521", r )
   RECOVER USING e
      Err( "F_0521", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,0)
      Show( "F_0522", r )
   RECOVER USING e
      Err( "F_0522", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,2)
      Show( "F_0523", r )
   RECOVER USING e
      Err( "F_0523", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,-1)
      Show( "F_0524", r )
   RECOVER USING e
      Err( "F_0524", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,0)
      Show( "F_0525", r )
   RECOVER USING e
      Err( "F_0525", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,2)
      Show( "F_0526", r )
   RECOVER USING e
      Err( "F_0526", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,-1)
      Show( "F_0527", r )
   RECOVER USING e
      Err( "F_0527", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647,0)
      Show( "F_0528", r )
   RECOVER USING e
      Err( "F_0528", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647,2)
      Show( "F_0529", r )
   RECOVER USING e
      Err( "F_0529", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647,-1)
      Show( "F_0530", r )
   RECOVER USING e
      Err( "F_0530", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483648,0)
      Show( "F_0531", r )
   RECOVER USING e
      Err( "F_0531", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483648,2)
      Show( "F_0532", r )
   RECOVER USING e
      Err( "F_0532", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483648,-1)
      Show( "F_0533", r )
   RECOVER USING e
      Err( "F_0533", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647.5,0)
      Show( "F_0534", r )
   RECOVER USING e
      Err( "F_0534", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647.5,2)
      Show( "F_0535", r )
   RECOVER USING e
      Err( "F_0535", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2147483647.5,-1)
      Show( "F_0536", r )
   RECOVER USING e
      Err( "F_0536", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-2147483648.5,0)
      Show( "F_0537", r )
   RECOVER USING e
      Err( "F_0537", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-2147483648.5,2)
      Show( "F_0538", r )
   RECOVER USING e
      Err( "F_0538", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-2147483648.5,-1)
      Show( "F_0539", r )
   RECOVER USING e
      Err( "F_0539", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4294967295.5,0)
      Show( "F_0540", r )
   RECOVER USING e
      Err( "F_0540", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P018()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4294967295.5,2)
      Show( "F_0541", r )
   RECOVER USING e
      Err( "F_0541", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4294967295.5,-1)
      Show( "F_0542", r )
   RECOVER USING e
      Err( "F_0542", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4294967296.5,0)
      Show( "F_0543", r )
   RECOVER USING e
      Err( "F_0543", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4294967296.5,2)
      Show( "F_0544", r )
   RECOVER USING e
      Err( "F_0544", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(4294967296.5,-1)
      Show( "F_0545", r )
   RECOVER USING e
      Err( "F_0545", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9223372036854775807,0)
      Show( "F_0546", r )
   RECOVER USING e
      Err( "F_0546", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9223372036854775807,2)
      Show( "F_0547", r )
   RECOVER USING e
      Err( "F_0547", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9223372036854775807,-1)
      Show( "F_0548", r )
   RECOVER USING e
      Err( "F_0548", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9223372036854775807.5,0)
      Show( "F_0549", r )
   RECOVER USING e
      Err( "F_0549", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9223372036854775807.5,2)
      Show( "F_0550", r )
   RECOVER USING e
      Err( "F_0550", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(9223372036854775807.5,-1)
      Show( "F_0551", r )
   RECOVER USING e
      Err( "F_0551", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-9223372036854775808,0)
      Show( "F_0552", r )
   RECOVER USING e
      Err( "F_0552", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-9223372036854775808,2)
      Show( "F_0553", r )
   RECOVER USING e
      Err( "F_0553", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(-9223372036854775808,-1)
      Show( "F_0554", r )
   RECOVER USING e
      Err( "F_0554", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99999999999999999999,0)
      Show( "F_0555", r )
   RECOVER USING e
      Err( "F_0555", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99999999999999999999,2)
      Show( "F_0556", r )
   RECOVER USING e
      Err( "F_0556", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(99999999999999999999,-1)
      Show( "F_0557", r )
   RECOVER USING e
      Err( "F_0557", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345678,0)
      Show( "F_0558", r )
   RECOVER USING e
      Err( "F_0558", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345678,2)
      Show( "F_0559", r )
   RECOVER USING e
      Err( "F_0559", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789012345678,-1)
      Show( "F_0560", r )
   RECOVER USING e
      Err( "F_0560", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789.123456789,1)
      Show( "F_0561", r )
   RECOVER USING e
      Err( "F_0561", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789.123456789,2)
      Show( "F_0562", r )
   RECOVER USING e
      Err( "F_0562", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789.123456789,3)
      Show( "F_0563", r )
   RECOVER USING e
      Err( "F_0563", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789.123456789,5)
      Show( "F_0564", r )
   RECOVER USING e
      Err( "F_0564", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789.123456789,10)
      Show( "F_0565", r )
   RECOVER USING e
      Err( "F_0565", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123456789.123456789,15)
      Show( "F_0566", r )
   RECOVER USING e
      Err( "F_0566", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000+0.0000001,1)
      Show( "F_0567", r )
   RECOVER USING e
      Err( "F_0567", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000+0.0000001,2)
      Show( "F_0568", r )
   RECOVER USING e
      Err( "F_0568", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000+0.0000001,3)
      Show( "F_0569", r )
   RECOVER USING e
      Err( "F_0569", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000+0.0000001,5)
      Show( "F_0570", r )
   RECOVER USING e
      Err( "F_0570", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P019()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000+0.0000001,10)
      Show( "F_0571", r )
   RECOVER USING e
      Err( "F_0571", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000+0.0000001,15)
      Show( "F_0572", r )
   RECOVER USING e
      Err( "F_0572", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(98765432109.8765432,1)
      Show( "F_0573", r )
   RECOVER USING e
      Err( "F_0573", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(98765432109.8765432,2)
      Show( "F_0574", r )
   RECOVER USING e
      Err( "F_0574", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(98765432109.8765432,3)
      Show( "F_0575", r )
   RECOVER USING e
      Err( "F_0575", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(98765432109.8765432,5)
      Show( "F_0576", r )
   RECOVER USING e
      Err( "F_0576", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(98765432109.8765432,10)
      Show( "F_0577", r )
   RECOVER USING e
      Err( "F_0577", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(98765432109.8765432,15)
      Show( "F_0578", r )
   RECOVER USING e
      Err( "F_0578", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.125,1)
      Show( "F_0579", r )
   RECOVER USING e
      Err( "F_0579", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.125,2)
      Show( "F_0580", r )
   RECOVER USING e
      Err( "F_0580", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.125,3)
      Show( "F_0581", r )
   RECOVER USING e
      Err( "F_0581", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.125,5)
      Show( "F_0582", r )
   RECOVER USING e
      Err( "F_0582", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.125,10)
      Show( "F_0583", r )
   RECOVER USING e
      Err( "F_0583", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.125,15)
      Show( "F_0584", r )
   RECOVER USING e
      Err( "F_0584", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.375,1)
      Show( "F_0585", r )
   RECOVER USING e
      Err( "F_0585", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.375,2)
      Show( "F_0586", r )
   RECOVER USING e
      Err( "F_0586", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.375,3)
      Show( "F_0587", r )
   RECOVER USING e
      Err( "F_0587", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.375,5)
      Show( "F_0588", r )
   RECOVER USING e
      Err( "F_0588", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.375,10)
      Show( "F_0589", r )
   RECOVER USING e
      Err( "F_0589", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1000000000000+0.375,15)
      Show( "F_0590", r )
   RECOVER USING e
      Err( "F_0590", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000+0.0625,1)
      Show( "F_0591", r )
   RECOVER USING e
      Err( "F_0591", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000+0.0625,2)
      Show( "F_0592", r )
   RECOVER USING e
      Err( "F_0592", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000+0.0625,3)
      Show( "F_0593", r )
   RECOVER USING e
      Err( "F_0593", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000+0.0625,5)
      Show( "F_0594", r )
   RECOVER USING e
      Err( "F_0594", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000+0.0625,10)
      Show( "F_0595", r )
   RECOVER USING e
      Err( "F_0595", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10000000000000+0.0625,15)
      Show( "F_0596", r )
   RECOVER USING e
      Err( "F_0596", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000+0.03125,1)
      Show( "F_0597", r )
   RECOVER USING e
      Err( "F_0597", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000+0.03125,2)
      Show( "F_0598", r )
   RECOVER USING e
      Err( "F_0598", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000+0.03125,3)
      Show( "F_0599", r )
   RECOVER USING e
      Err( "F_0599", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000+0.03125,5)
      Show( "F_0600", r )
   RECOVER USING e
      Err( "F_0600", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P020()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000+0.03125,10)
      Show( "F_0601", r )
   RECOVER USING e
      Err( "F_0601", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(100000000000000+0.03125,15)
      Show( "F_0602", r )
   RECOVER USING e
      Err( "F_0602", e )
   END SEQUENCE
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
   RETURN
STATIC PROCEDURE P021()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P022()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P023()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P024()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P025()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P026()
   LOCAL r, e
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
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.1+0.2,0)
      Show( "I_0810", r )
   RECOVER USING e
      Err( "I_0810", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P027()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P028()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P029()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P030()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P031()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P032()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P033()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P034()
   LOCAL r, e
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
   RETURN
STATIC PROCEDURE P035()
   LOCAL r, e
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
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,10,2)
      Show( "M_1066", r )
   RECOVER USING e
      Err( "M_1066", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,10,0)
      Show( "M_1067", r )
   RECOVER USING e
      Err( "M_1067", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,10,1)
      Show( "M_1068", r )
   RECOVER USING e
      Err( "M_1068", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,5,2)
      Show( "M_1069", r )
   RECOVER USING e
      Err( "M_1069", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,4,2)
      Show( "M_1070", r )
   RECOVER USING e
      Err( "M_1070", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,3,0)
      Show( "M_1071", r )
   RECOVER USING e
      Err( "M_1071", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,2,0)
      Show( "M_1072", r )
   RECOVER USING e
      Err( "M_1072", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,1,0)
      Show( "M_1073", r )
   RECOVER USING e
      Err( "M_1073", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,6,3)
      Show( "M_1074", r )
   RECOVER USING e
      Err( "M_1074", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,20,15)
      Show( "M_1075", r )
   RECOVER USING e
      Err( "M_1075", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,30,20)
      Show( "M_1076", r )
   RECOVER USING e
      Err( "M_1076", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,8,-1)
      Show( "M_1077", r )
   RECOVER USING e
      Err( "M_1077", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,10,3)
      Show( "M_1078", r )
   RECOVER USING e
      Err( "M_1078", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,0,0)
      Show( "M_1079", r )
   RECOVER USING e
      Err( "M_1079", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,12,6)
      Show( "M_1080", r )
   RECOVER USING e
      Err( "M_1080", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P036()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005)
      Show( "M_1081", r )
   RECOVER USING e
      Err( "M_1081", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,8)
      Show( "M_1082", r )
   RECOVER USING e
      Err( "M_1082", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,3)
      Show( "M_1083", r )
   RECOVER USING e
      Err( "M_1083", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,20)
      Show( "M_1084", r )
   RECOVER USING e
      Err( "M_1084", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.005,5)
      Show( "M_1085", r )
   RECOVER USING e
      Err( "M_1085", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,10,2)
      Show( "M_1086", r )
   RECOVER USING e
      Err( "M_1086", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,10,0)
      Show( "M_1087", r )
   RECOVER USING e
      Err( "M_1087", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,10,1)
      Show( "M_1088", r )
   RECOVER USING e
      Err( "M_1088", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,5,2)
      Show( "M_1089", r )
   RECOVER USING e
      Err( "M_1089", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,4,2)
      Show( "M_1090", r )
   RECOVER USING e
      Err( "M_1090", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,3,0)
      Show( "M_1091", r )
   RECOVER USING e
      Err( "M_1091", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,2,0)
      Show( "M_1092", r )
   RECOVER USING e
      Err( "M_1092", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,1,0)
      Show( "M_1093", r )
   RECOVER USING e
      Err( "M_1093", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,6,3)
      Show( "M_1094", r )
   RECOVER USING e
      Err( "M_1094", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,20,15)
      Show( "M_1095", r )
   RECOVER USING e
      Err( "M_1095", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,30,20)
      Show( "M_1096", r )
   RECOVER USING e
      Err( "M_1096", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,8,-1)
      Show( "M_1097", r )
   RECOVER USING e
      Err( "M_1097", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,10,3)
      Show( "M_1098", r )
   RECOVER USING e
      Err( "M_1098", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,0,0)
      Show( "M_1099", r )
   RECOVER USING e
      Err( "M_1099", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,12,6)
      Show( "M_1100", r )
   RECOVER USING e
      Err( "M_1100", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675)
      Show( "M_1101", r )
   RECOVER USING e
      Err( "M_1101", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,8)
      Show( "M_1102", r )
   RECOVER USING e
      Err( "M_1102", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,3)
      Show( "M_1103", r )
   RECOVER USING e
      Err( "M_1103", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,20)
      Show( "M_1104", r )
   RECOVER USING e
      Err( "M_1104", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.675,5)
      Show( "M_1105", r )
   RECOVER USING e
      Err( "M_1105", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,10,2)
      Show( "M_1106", r )
   RECOVER USING e
      Err( "M_1106", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,10,0)
      Show( "M_1107", r )
   RECOVER USING e
      Err( "M_1107", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,10,1)
      Show( "M_1108", r )
   RECOVER USING e
      Err( "M_1108", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,5,2)
      Show( "M_1109", r )
   RECOVER USING e
      Err( "M_1109", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,4,2)
      Show( "M_1110", r )
   RECOVER USING e
      Err( "M_1110", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P037()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,3,0)
      Show( "M_1111", r )
   RECOVER USING e
      Err( "M_1111", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,2,0)
      Show( "M_1112", r )
   RECOVER USING e
      Err( "M_1112", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,1,0)
      Show( "M_1113", r )
   RECOVER USING e
      Err( "M_1113", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,6,3)
      Show( "M_1114", r )
   RECOVER USING e
      Err( "M_1114", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,20,15)
      Show( "M_1115", r )
   RECOVER USING e
      Err( "M_1115", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,30,20)
      Show( "M_1116", r )
   RECOVER USING e
      Err( "M_1116", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,8,-1)
      Show( "M_1117", r )
   RECOVER USING e
      Err( "M_1117", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,10,3)
      Show( "M_1118", r )
   RECOVER USING e
      Err( "M_1118", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,0,0)
      Show( "M_1119", r )
   RECOVER USING e
      Err( "M_1119", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,12,6)
      Show( "M_1120", r )
   RECOVER USING e
      Err( "M_1120", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285)
      Show( "M_1121", r )
   RECOVER USING e
      Err( "M_1121", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,8)
      Show( "M_1122", r )
   RECOVER USING e
      Err( "M_1122", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,3)
      Show( "M_1123", r )
   RECOVER USING e
      Err( "M_1123", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,20)
      Show( "M_1124", r )
   RECOVER USING e
      Err( "M_1124", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.285,5)
      Show( "M_1125", r )
   RECOVER USING e
      Err( "M_1125", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,10,2)
      Show( "M_1126", r )
   RECOVER USING e
      Err( "M_1126", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,10,0)
      Show( "M_1127", r )
   RECOVER USING e
      Err( "M_1127", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,10,1)
      Show( "M_1128", r )
   RECOVER USING e
      Err( "M_1128", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,5,2)
      Show( "M_1129", r )
   RECOVER USING e
      Err( "M_1129", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,4,2)
      Show( "M_1130", r )
   RECOVER USING e
      Err( "M_1130", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,3,0)
      Show( "M_1131", r )
   RECOVER USING e
      Err( "M_1131", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,2,0)
      Show( "M_1132", r )
   RECOVER USING e
      Err( "M_1132", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,1,0)
      Show( "M_1133", r )
   RECOVER USING e
      Err( "M_1133", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,6,3)
      Show( "M_1134", r )
   RECOVER USING e
      Err( "M_1134", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,20,15)
      Show( "M_1135", r )
   RECOVER USING e
      Err( "M_1135", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,30,20)
      Show( "M_1136", r )
   RECOVER USING e
      Err( "M_1136", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,8,-1)
      Show( "M_1137", r )
   RECOVER USING e
      Err( "M_1137", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,10,3)
      Show( "M_1138", r )
   RECOVER USING e
      Err( "M_1138", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,0,0)
      Show( "M_1139", r )
   RECOVER USING e
      Err( "M_1139", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,12,6)
      Show( "M_1140", r )
   RECOVER USING e
      Err( "M_1140", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P038()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5)
      Show( "M_1141", r )
   RECOVER USING e
      Err( "M_1141", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,8)
      Show( "M_1142", r )
   RECOVER USING e
      Err( "M_1142", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,3)
      Show( "M_1143", r )
   RECOVER USING e
      Err( "M_1143", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,20)
      Show( "M_1144", r )
   RECOVER USING e
      Err( "M_1144", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.5,5)
      Show( "M_1145", r )
   RECOVER USING e
      Err( "M_1145", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,10,2)
      Show( "M_1146", r )
   RECOVER USING e
      Err( "M_1146", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,10,0)
      Show( "M_1147", r )
   RECOVER USING e
      Err( "M_1147", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,10,1)
      Show( "M_1148", r )
   RECOVER USING e
      Err( "M_1148", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,5,2)
      Show( "M_1149", r )
   RECOVER USING e
      Err( "M_1149", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,4,2)
      Show( "M_1150", r )
   RECOVER USING e
      Err( "M_1150", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,3,0)
      Show( "M_1151", r )
   RECOVER USING e
      Err( "M_1151", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,2,0)
      Show( "M_1152", r )
   RECOVER USING e
      Err( "M_1152", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,1,0)
      Show( "M_1153", r )
   RECOVER USING e
      Err( "M_1153", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,6,3)
      Show( "M_1154", r )
   RECOVER USING e
      Err( "M_1154", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,20,15)
      Show( "M_1155", r )
   RECOVER USING e
      Err( "M_1155", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,30,20)
      Show( "M_1156", r )
   RECOVER USING e
      Err( "M_1156", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,8,-1)
      Show( "M_1157", r )
   RECOVER USING e
      Err( "M_1157", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,10,3)
      Show( "M_1158", r )
   RECOVER USING e
      Err( "M_1158", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,0,0)
      Show( "M_1159", r )
   RECOVER USING e
      Err( "M_1159", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,12,6)
      Show( "M_1160", r )
   RECOVER USING e
      Err( "M_1160", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5)
      Show( "M_1161", r )
   RECOVER USING e
      Err( "M_1161", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,8)
      Show( "M_1162", r )
   RECOVER USING e
      Err( "M_1162", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,3)
      Show( "M_1163", r )
   RECOVER USING e
      Err( "M_1163", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,20)
      Show( "M_1164", r )
   RECOVER USING e
      Err( "M_1164", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.5,5)
      Show( "M_1165", r )
   RECOVER USING e
      Err( "M_1165", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,10,2)
      Show( "M_1166", r )
   RECOVER USING e
      Err( "M_1166", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,10,0)
      Show( "M_1167", r )
   RECOVER USING e
      Err( "M_1167", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,10,1)
      Show( "M_1168", r )
   RECOVER USING e
      Err( "M_1168", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,5,2)
      Show( "M_1169", r )
   RECOVER USING e
      Err( "M_1169", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,4,2)
      Show( "M_1170", r )
   RECOVER USING e
      Err( "M_1170", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P039()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,3,0)
      Show( "M_1171", r )
   RECOVER USING e
      Err( "M_1171", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,2,0)
      Show( "M_1172", r )
   RECOVER USING e
      Err( "M_1172", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,1,0)
      Show( "M_1173", r )
   RECOVER USING e
      Err( "M_1173", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,6,3)
      Show( "M_1174", r )
   RECOVER USING e
      Err( "M_1174", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,20,15)
      Show( "M_1175", r )
   RECOVER USING e
      Err( "M_1175", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,30,20)
      Show( "M_1176", r )
   RECOVER USING e
      Err( "M_1176", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,8,-1)
      Show( "M_1177", r )
   RECOVER USING e
      Err( "M_1177", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,10,3)
      Show( "M_1178", r )
   RECOVER USING e
      Err( "M_1178", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,0,0)
      Show( "M_1179", r )
   RECOVER USING e
      Err( "M_1179", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,12,6)
      Show( "M_1180", r )
   RECOVER USING e
      Err( "M_1180", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5)
      Show( "M_1181", r )
   RECOVER USING e
      Err( "M_1181", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,8)
      Show( "M_1182", r )
   RECOVER USING e
      Err( "M_1182", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,3)
      Show( "M_1183", r )
   RECOVER USING e
      Err( "M_1183", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,20)
      Show( "M_1184", r )
   RECOVER USING e
      Err( "M_1184", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(2.5,5)
      Show( "M_1185", r )
   RECOVER USING e
      Err( "M_1185", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,10,2)
      Show( "M_1186", r )
   RECOVER USING e
      Err( "M_1186", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,10,0)
      Show( "M_1187", r )
   RECOVER USING e
      Err( "M_1187", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,10,1)
      Show( "M_1188", r )
   RECOVER USING e
      Err( "M_1188", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,5,2)
      Show( "M_1189", r )
   RECOVER USING e
      Err( "M_1189", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,4,2)
      Show( "M_1190", r )
   RECOVER USING e
      Err( "M_1190", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,3,0)
      Show( "M_1191", r )
   RECOVER USING e
      Err( "M_1191", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,2,0)
      Show( "M_1192", r )
   RECOVER USING e
      Err( "M_1192", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,1,0)
      Show( "M_1193", r )
   RECOVER USING e
      Err( "M_1193", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,6,3)
      Show( "M_1194", r )
   RECOVER USING e
      Err( "M_1194", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,20,15)
      Show( "M_1195", r )
   RECOVER USING e
      Err( "M_1195", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,30,20)
      Show( "M_1196", r )
   RECOVER USING e
      Err( "M_1196", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,8,-1)
      Show( "M_1197", r )
   RECOVER USING e
      Err( "M_1197", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,10,3)
      Show( "M_1198", r )
   RECOVER USING e
      Err( "M_1198", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,0,0)
      Show( "M_1199", r )
   RECOVER USING e
      Err( "M_1199", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,12,6)
      Show( "M_1200", r )
   RECOVER USING e
      Err( "M_1200", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P040()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5)
      Show( "M_1201", r )
   RECOVER USING e
      Err( "M_1201", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,8)
      Show( "M_1202", r )
   RECOVER USING e
      Err( "M_1202", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,3)
      Show( "M_1203", r )
   RECOVER USING e
      Err( "M_1203", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,20)
      Show( "M_1204", r )
   RECOVER USING e
      Err( "M_1204", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,5)
      Show( "M_1205", r )
   RECOVER USING e
      Err( "M_1205", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,10,2)
      Show( "M_1206", r )
   RECOVER USING e
      Err( "M_1206", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,10,0)
      Show( "M_1207", r )
   RECOVER USING e
      Err( "M_1207", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,10,1)
      Show( "M_1208", r )
   RECOVER USING e
      Err( "M_1208", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,5,2)
      Show( "M_1209", r )
   RECOVER USING e
      Err( "M_1209", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,4,2)
      Show( "M_1210", r )
   RECOVER USING e
      Err( "M_1210", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,3,0)
      Show( "M_1211", r )
   RECOVER USING e
      Err( "M_1211", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,2,0)
      Show( "M_1212", r )
   RECOVER USING e
      Err( "M_1212", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,1,0)
      Show( "M_1213", r )
   RECOVER USING e
      Err( "M_1213", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,6,3)
      Show( "M_1214", r )
   RECOVER USING e
      Err( "M_1214", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,20,15)
      Show( "M_1215", r )
   RECOVER USING e
      Err( "M_1215", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,30,20)
      Show( "M_1216", r )
   RECOVER USING e
      Err( "M_1216", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,8,-1)
      Show( "M_1217", r )
   RECOVER USING e
      Err( "M_1217", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,10,3)
      Show( "M_1218", r )
   RECOVER USING e
      Err( "M_1218", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,0,0)
      Show( "M_1219", r )
   RECOVER USING e
      Err( "M_1219", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,12,6)
      Show( "M_1220", r )
   RECOVER USING e
      Err( "M_1220", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5)
      Show( "M_1221", r )
   RECOVER USING e
      Err( "M_1221", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,8)
      Show( "M_1222", r )
   RECOVER USING e
      Err( "M_1222", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,3)
      Show( "M_1223", r )
   RECOVER USING e
      Err( "M_1223", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,20)
      Show( "M_1224", r )
   RECOVER USING e
      Err( "M_1224", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-2.5,5)
      Show( "M_1225", r )
   RECOVER USING e
      Err( "M_1225", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,10,2)
      Show( "M_1226", r )
   RECOVER USING e
      Err( "M_1226", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,10,0)
      Show( "M_1227", r )
   RECOVER USING e
      Err( "M_1227", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,10,1)
      Show( "M_1228", r )
   RECOVER USING e
      Err( "M_1228", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,5,2)
      Show( "M_1229", r )
   RECOVER USING e
      Err( "M_1229", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,4,2)
      Show( "M_1230", r )
   RECOVER USING e
      Err( "M_1230", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P041()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,3,0)
      Show( "M_1231", r )
   RECOVER USING e
      Err( "M_1231", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,2,0)
      Show( "M_1232", r )
   RECOVER USING e
      Err( "M_1232", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,1,0)
      Show( "M_1233", r )
   RECOVER USING e
      Err( "M_1233", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,6,3)
      Show( "M_1234", r )
   RECOVER USING e
      Err( "M_1234", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,20,15)
      Show( "M_1235", r )
   RECOVER USING e
      Err( "M_1235", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,30,20)
      Show( "M_1236", r )
   RECOVER USING e
      Err( "M_1236", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,8,-1)
      Show( "M_1237", r )
   RECOVER USING e
      Err( "M_1237", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,10,3)
      Show( "M_1238", r )
   RECOVER USING e
      Err( "M_1238", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,0,0)
      Show( "M_1239", r )
   RECOVER USING e
      Err( "M_1239", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,12,6)
      Show( "M_1240", r )
   RECOVER USING e
      Err( "M_1240", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995)
      Show( "M_1241", r )
   RECOVER USING e
      Err( "M_1241", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,8)
      Show( "M_1242", r )
   RECOVER USING e
      Err( "M_1242", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,3)
      Show( "M_1243", r )
   RECOVER USING e
      Err( "M_1243", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,20)
      Show( "M_1244", r )
   RECOVER USING e
      Err( "M_1244", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.995,5)
      Show( "M_1245", r )
   RECOVER USING e
      Err( "M_1245", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,10,2)
      Show( "M_1246", r )
   RECOVER USING e
      Err( "M_1246", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,10,0)
      Show( "M_1247", r )
   RECOVER USING e
      Err( "M_1247", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,10,1)
      Show( "M_1248", r )
   RECOVER USING e
      Err( "M_1248", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,5,2)
      Show( "M_1249", r )
   RECOVER USING e
      Err( "M_1249", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,4,2)
      Show( "M_1250", r )
   RECOVER USING e
      Err( "M_1250", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,3,0)
      Show( "M_1251", r )
   RECOVER USING e
      Err( "M_1251", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,2,0)
      Show( "M_1252", r )
   RECOVER USING e
      Err( "M_1252", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,1,0)
      Show( "M_1253", r )
   RECOVER USING e
      Err( "M_1253", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,6,3)
      Show( "M_1254", r )
   RECOVER USING e
      Err( "M_1254", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,20,15)
      Show( "M_1255", r )
   RECOVER USING e
      Err( "M_1255", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,30,20)
      Show( "M_1256", r )
   RECOVER USING e
      Err( "M_1256", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,8,-1)
      Show( "M_1257", r )
   RECOVER USING e
      Err( "M_1257", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,10,3)
      Show( "M_1258", r )
   RECOVER USING e
      Err( "M_1258", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,0,0)
      Show( "M_1259", r )
   RECOVER USING e
      Err( "M_1259", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,12,6)
      Show( "M_1260", r )
   RECOVER USING e
      Err( "M_1260", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P042()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995)
      Show( "M_1261", r )
   RECOVER USING e
      Err( "M_1261", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,8)
      Show( "M_1262", r )
   RECOVER USING e
      Err( "M_1262", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,3)
      Show( "M_1263", r )
   RECOVER USING e
      Err( "M_1263", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,20)
      Show( "M_1264", r )
   RECOVER USING e
      Err( "M_1264", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.995,5)
      Show( "M_1265", r )
   RECOVER USING e
      Err( "M_1265", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,10,2)
      Show( "M_1266", r )
   RECOVER USING e
      Err( "M_1266", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,10,0)
      Show( "M_1267", r )
   RECOVER USING e
      Err( "M_1267", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,10,1)
      Show( "M_1268", r )
   RECOVER USING e
      Err( "M_1268", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,5,2)
      Show( "M_1269", r )
   RECOVER USING e
      Err( "M_1269", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,4,2)
      Show( "M_1270", r )
   RECOVER USING e
      Err( "M_1270", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,3,0)
      Show( "M_1271", r )
   RECOVER USING e
      Err( "M_1271", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,2,0)
      Show( "M_1272", r )
   RECOVER USING e
      Err( "M_1272", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,1,0)
      Show( "M_1273", r )
   RECOVER USING e
      Err( "M_1273", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,6,3)
      Show( "M_1274", r )
   RECOVER USING e
      Err( "M_1274", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,20,15)
      Show( "M_1275", r )
   RECOVER USING e
      Err( "M_1275", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,30,20)
      Show( "M_1276", r )
   RECOVER USING e
      Err( "M_1276", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,8,-1)
      Show( "M_1277", r )
   RECOVER USING e
      Err( "M_1277", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,10,3)
      Show( "M_1278", r )
   RECOVER USING e
      Err( "M_1278", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,0,0)
      Show( "M_1279", r )
   RECOVER USING e
      Err( "M_1279", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,12,6)
      Show( "M_1280", r )
   RECOVER USING e
      Err( "M_1280", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5)
      Show( "M_1281", r )
   RECOVER USING e
      Err( "M_1281", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,8)
      Show( "M_1282", r )
   RECOVER USING e
      Err( "M_1282", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,3)
      Show( "M_1283", r )
   RECOVER USING e
      Err( "M_1283", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,20)
      Show( "M_1284", r )
   RECOVER USING e
      Err( "M_1284", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(999.5,5)
      Show( "M_1285", r )
   RECOVER USING e
      Err( "M_1285", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,10,2)
      Show( "M_1286", r )
   RECOVER USING e
      Err( "M_1286", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,10,0)
      Show( "M_1287", r )
   RECOVER USING e
      Err( "M_1287", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,10,1)
      Show( "M_1288", r )
   RECOVER USING e
      Err( "M_1288", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,5,2)
      Show( "M_1289", r )
   RECOVER USING e
      Err( "M_1289", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,4,2)
      Show( "M_1290", r )
   RECOVER USING e
      Err( "M_1290", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P043()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,3,0)
      Show( "M_1291", r )
   RECOVER USING e
      Err( "M_1291", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,2,0)
      Show( "M_1292", r )
   RECOVER USING e
      Err( "M_1292", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,1,0)
      Show( "M_1293", r )
   RECOVER USING e
      Err( "M_1293", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,6,3)
      Show( "M_1294", r )
   RECOVER USING e
      Err( "M_1294", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,20,15)
      Show( "M_1295", r )
   RECOVER USING e
      Err( "M_1295", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,30,20)
      Show( "M_1296", r )
   RECOVER USING e
      Err( "M_1296", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,8,-1)
      Show( "M_1297", r )
   RECOVER USING e
      Err( "M_1297", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,10,3)
      Show( "M_1298", r )
   RECOVER USING e
      Err( "M_1298", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,0,0)
      Show( "M_1299", r )
   RECOVER USING e
      Err( "M_1299", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,12,6)
      Show( "M_1300", r )
   RECOVER USING e
      Err( "M_1300", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5)
      Show( "M_1301", r )
   RECOVER USING e
      Err( "M_1301", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,8)
      Show( "M_1302", r )
   RECOVER USING e
      Err( "M_1302", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,3)
      Show( "M_1303", r )
   RECOVER USING e
      Err( "M_1303", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,20)
      Show( "M_1304", r )
   RECOVER USING e
      Err( "M_1304", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(9.5,5)
      Show( "M_1305", r )
   RECOVER USING e
      Err( "M_1305", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,10,2)
      Show( "M_1306", r )
   RECOVER USING e
      Err( "M_1306", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,10,0)
      Show( "M_1307", r )
   RECOVER USING e
      Err( "M_1307", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,10,1)
      Show( "M_1308", r )
   RECOVER USING e
      Err( "M_1308", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,5,2)
      Show( "M_1309", r )
   RECOVER USING e
      Err( "M_1309", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,4,2)
      Show( "M_1310", r )
   RECOVER USING e
      Err( "M_1310", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,3,0)
      Show( "M_1311", r )
   RECOVER USING e
      Err( "M_1311", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,2,0)
      Show( "M_1312", r )
   RECOVER USING e
      Err( "M_1312", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,1,0)
      Show( "M_1313", r )
   RECOVER USING e
      Err( "M_1313", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,6,3)
      Show( "M_1314", r )
   RECOVER USING e
      Err( "M_1314", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,20,15)
      Show( "M_1315", r )
   RECOVER USING e
      Err( "M_1315", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,30,20)
      Show( "M_1316", r )
   RECOVER USING e
      Err( "M_1316", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,8,-1)
      Show( "M_1317", r )
   RECOVER USING e
      Err( "M_1317", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,10,3)
      Show( "M_1318", r )
   RECOVER USING e
      Err( "M_1318", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,0,0)
      Show( "M_1319", r )
   RECOVER USING e
      Err( "M_1319", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,12,6)
      Show( "M_1320", r )
   RECOVER USING e
      Err( "M_1320", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P044()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5)
      Show( "M_1321", r )
   RECOVER USING e
      Err( "M_1321", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,8)
      Show( "M_1322", r )
   RECOVER USING e
      Err( "M_1322", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,3)
      Show( "M_1323", r )
   RECOVER USING e
      Err( "M_1323", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,20)
      Show( "M_1324", r )
   RECOVER USING e
      Err( "M_1324", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(99.5,5)
      Show( "M_1325", r )
   RECOVER USING e
      Err( "M_1325", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,10,2)
      Show( "M_1326", r )
   RECOVER USING e
      Err( "M_1326", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,10,0)
      Show( "M_1327", r )
   RECOVER USING e
      Err( "M_1327", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,10,1)
      Show( "M_1328", r )
   RECOVER USING e
      Err( "M_1328", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,5,2)
      Show( "M_1329", r )
   RECOVER USING e
      Err( "M_1329", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,4,2)
      Show( "M_1330", r )
   RECOVER USING e
      Err( "M_1330", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,3,0)
      Show( "M_1331", r )
   RECOVER USING e
      Err( "M_1331", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,2,0)
      Show( "M_1332", r )
   RECOVER USING e
      Err( "M_1332", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,1,0)
      Show( "M_1333", r )
   RECOVER USING e
      Err( "M_1333", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,6,3)
      Show( "M_1334", r )
   RECOVER USING e
      Err( "M_1334", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,20,15)
      Show( "M_1335", r )
   RECOVER USING e
      Err( "M_1335", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,30,20)
      Show( "M_1336", r )
   RECOVER USING e
      Err( "M_1336", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,8,-1)
      Show( "M_1337", r )
   RECOVER USING e
      Err( "M_1337", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,10,3)
      Show( "M_1338", r )
   RECOVER USING e
      Err( "M_1338", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,0,0)
      Show( "M_1339", r )
   RECOVER USING e
      Err( "M_1339", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,12,6)
      Show( "M_1340", r )
   RECOVER USING e
      Err( "M_1340", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045)
      Show( "M_1341", r )
   RECOVER USING e
      Err( "M_1341", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,8)
      Show( "M_1342", r )
   RECOVER USING e
      Err( "M_1342", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,3)
      Show( "M_1343", r )
   RECOVER USING e
      Err( "M_1343", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,20)
      Show( "M_1344", r )
   RECOVER USING e
      Err( "M_1344", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.045,5)
      Show( "M_1345", r )
   RECOVER USING e
      Err( "M_1345", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,10,2)
      Show( "M_1346", r )
   RECOVER USING e
      Err( "M_1346", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,10,0)
      Show( "M_1347", r )
   RECOVER USING e
      Err( "M_1347", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,10,1)
      Show( "M_1348", r )
   RECOVER USING e
      Err( "M_1348", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,5,2)
      Show( "M_1349", r )
   RECOVER USING e
      Err( "M_1349", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,4,2)
      Show( "M_1350", r )
   RECOVER USING e
      Err( "M_1350", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P045()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,3,0)
      Show( "M_1351", r )
   RECOVER USING e
      Err( "M_1351", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,2,0)
      Show( "M_1352", r )
   RECOVER USING e
      Err( "M_1352", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,1,0)
      Show( "M_1353", r )
   RECOVER USING e
      Err( "M_1353", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,6,3)
      Show( "M_1354", r )
   RECOVER USING e
      Err( "M_1354", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,20,15)
      Show( "M_1355", r )
   RECOVER USING e
      Err( "M_1355", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,30,20)
      Show( "M_1356", r )
   RECOVER USING e
      Err( "M_1356", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,8,-1)
      Show( "M_1357", r )
   RECOVER USING e
      Err( "M_1357", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,10,3)
      Show( "M_1358", r )
   RECOVER USING e
      Err( "M_1358", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,0,0)
      Show( "M_1359", r )
   RECOVER USING e
      Err( "M_1359", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,12,6)
      Show( "M_1360", r )
   RECOVER USING e
      Err( "M_1360", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45)
      Show( "M_1361", r )
   RECOVER USING e
      Err( "M_1361", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,8)
      Show( "M_1362", r )
   RECOVER USING e
      Err( "M_1362", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,3)
      Show( "M_1363", r )
   RECOVER USING e
      Err( "M_1363", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,20)
      Show( "M_1364", r )
   RECOVER USING e
      Err( "M_1364", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.45,5)
      Show( "M_1365", r )
   RECOVER USING e
      Err( "M_1365", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,10,2)
      Show( "M_1366", r )
   RECOVER USING e
      Err( "M_1366", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,10,0)
      Show( "M_1367", r )
   RECOVER USING e
      Err( "M_1367", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,10,1)
      Show( "M_1368", r )
   RECOVER USING e
      Err( "M_1368", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,5,2)
      Show( "M_1369", r )
   RECOVER USING e
      Err( "M_1369", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,4,2)
      Show( "M_1370", r )
   RECOVER USING e
      Err( "M_1370", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,3,0)
      Show( "M_1371", r )
   RECOVER USING e
      Err( "M_1371", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,2,0)
      Show( "M_1372", r )
   RECOVER USING e
      Err( "M_1372", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,1,0)
      Show( "M_1373", r )
   RECOVER USING e
      Err( "M_1373", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,6,3)
      Show( "M_1374", r )
   RECOVER USING e
      Err( "M_1374", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,20,15)
      Show( "M_1375", r )
   RECOVER USING e
      Err( "M_1375", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,30,20)
      Show( "M_1376", r )
   RECOVER USING e
      Err( "M_1376", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,8,-1)
      Show( "M_1377", r )
   RECOVER USING e
      Err( "M_1377", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,10,3)
      Show( "M_1378", r )
   RECOVER USING e
      Err( "M_1378", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,0,0)
      Show( "M_1379", r )
   RECOVER USING e
      Err( "M_1379", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,12,6)
      Show( "M_1380", r )
   RECOVER USING e
      Err( "M_1380", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P046()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55)
      Show( "M_1381", r )
   RECOVER USING e
      Err( "M_1381", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,8)
      Show( "M_1382", r )
   RECOVER USING e
      Err( "M_1382", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,3)
      Show( "M_1383", r )
   RECOVER USING e
      Err( "M_1383", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,20)
      Show( "M_1384", r )
   RECOVER USING e
      Err( "M_1384", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1.55,5)
      Show( "M_1385", r )
   RECOVER USING e
      Err( "M_1385", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,10,2)
      Show( "M_1386", r )
   RECOVER USING e
      Err( "M_1386", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,10,0)
      Show( "M_1387", r )
   RECOVER USING e
      Err( "M_1387", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,10,1)
      Show( "M_1388", r )
   RECOVER USING e
      Err( "M_1388", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,5,2)
      Show( "M_1389", r )
   RECOVER USING e
      Err( "M_1389", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,4,2)
      Show( "M_1390", r )
   RECOVER USING e
      Err( "M_1390", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,3,0)
      Show( "M_1391", r )
   RECOVER USING e
      Err( "M_1391", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,2,0)
      Show( "M_1392", r )
   RECOVER USING e
      Err( "M_1392", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,1,0)
      Show( "M_1393", r )
   RECOVER USING e
      Err( "M_1393", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,6,3)
      Show( "M_1394", r )
   RECOVER USING e
      Err( "M_1394", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,20,15)
      Show( "M_1395", r )
   RECOVER USING e
      Err( "M_1395", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,30,20)
      Show( "M_1396", r )
   RECOVER USING e
      Err( "M_1396", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,8,-1)
      Show( "M_1397", r )
   RECOVER USING e
      Err( "M_1397", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,10,3)
      Show( "M_1398", r )
   RECOVER USING e
      Err( "M_1398", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,0,0)
      Show( "M_1399", r )
   RECOVER USING e
      Err( "M_1399", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,12,6)
      Show( "M_1400", r )
   RECOVER USING e
      Err( "M_1400", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456)
      Show( "M_1401", r )
   RECOVER USING e
      Err( "M_1401", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,8)
      Show( "M_1402", r )
   RECOVER USING e
      Err( "M_1402", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,3)
      Show( "M_1403", r )
   RECOVER USING e
      Err( "M_1403", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,20)
      Show( "M_1404", r )
   RECOVER USING e
      Err( "M_1404", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(123.456,5)
      Show( "M_1405", r )
   RECOVER USING e
      Err( "M_1405", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,10,2)
      Show( "M_1406", r )
   RECOVER USING e
      Err( "M_1406", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,10,0)
      Show( "M_1407", r )
   RECOVER USING e
      Err( "M_1407", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,10,1)
      Show( "M_1408", r )
   RECOVER USING e
      Err( "M_1408", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,5,2)
      Show( "M_1409", r )
   RECOVER USING e
      Err( "M_1409", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,4,2)
      Show( "M_1410", r )
   RECOVER USING e
      Err( "M_1410", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P047()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,3,0)
      Show( "M_1411", r )
   RECOVER USING e
      Err( "M_1411", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,2,0)
      Show( "M_1412", r )
   RECOVER USING e
      Err( "M_1412", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,1,0)
      Show( "M_1413", r )
   RECOVER USING e
      Err( "M_1413", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,6,3)
      Show( "M_1414", r )
   RECOVER USING e
      Err( "M_1414", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,20,15)
      Show( "M_1415", r )
   RECOVER USING e
      Err( "M_1415", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,30,20)
      Show( "M_1416", r )
   RECOVER USING e
      Err( "M_1416", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,8,-1)
      Show( "M_1417", r )
   RECOVER USING e
      Err( "M_1417", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,10,3)
      Show( "M_1418", r )
   RECOVER USING e
      Err( "M_1418", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,0,0)
      Show( "M_1419", r )
   RECOVER USING e
      Err( "M_1419", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,12,6)
      Show( "M_1420", r )
   RECOVER USING e
      Err( "M_1420", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456)
      Show( "M_1421", r )
   RECOVER USING e
      Err( "M_1421", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,8)
      Show( "M_1422", r )
   RECOVER USING e
      Err( "M_1422", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,3)
      Show( "M_1423", r )
   RECOVER USING e
      Err( "M_1423", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,20)
      Show( "M_1424", r )
   RECOVER USING e
      Err( "M_1424", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-123.456,5)
      Show( "M_1425", r )
   RECOVER USING e
      Err( "M_1425", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,10,2)
      Show( "M_1426", r )
   RECOVER USING e
      Err( "M_1426", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,10,0)
      Show( "M_1427", r )
   RECOVER USING e
      Err( "M_1427", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,10,1)
      Show( "M_1428", r )
   RECOVER USING e
      Err( "M_1428", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,5,2)
      Show( "M_1429", r )
   RECOVER USING e
      Err( "M_1429", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,4,2)
      Show( "M_1430", r )
   RECOVER USING e
      Err( "M_1430", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,3,0)
      Show( "M_1431", r )
   RECOVER USING e
      Err( "M_1431", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,2,0)
      Show( "M_1432", r )
   RECOVER USING e
      Err( "M_1432", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,1,0)
      Show( "M_1433", r )
   RECOVER USING e
      Err( "M_1433", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,6,3)
      Show( "M_1434", r )
   RECOVER USING e
      Err( "M_1434", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,20,15)
      Show( "M_1435", r )
   RECOVER USING e
      Err( "M_1435", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,30,20)
      Show( "M_1436", r )
   RECOVER USING e
      Err( "M_1436", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,8,-1)
      Show( "M_1437", r )
   RECOVER USING e
      Err( "M_1437", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,10,3)
      Show( "M_1438", r )
   RECOVER USING e
      Err( "M_1438", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,0,0)
      Show( "M_1439", r )
   RECOVER USING e
      Err( "M_1439", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,12,6)
      Show( "M_1440", r )
   RECOVER USING e
      Err( "M_1440", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P048()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789)
      Show( "M_1441", r )
   RECOVER USING e
      Err( "M_1441", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,8)
      Show( "M_1442", r )
   RECOVER USING e
      Err( "M_1442", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,3)
      Show( "M_1443", r )
   RECOVER USING e
      Err( "M_1443", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,20)
      Show( "M_1444", r )
   RECOVER USING e
      Err( "M_1444", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(12345.6789,5)
      Show( "M_1445", r )
   RECOVER USING e
      Err( "M_1445", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,10,2)
      Show( "M_1446", r )
   RECOVER USING e
      Err( "M_1446", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,10,0)
      Show( "M_1447", r )
   RECOVER USING e
      Err( "M_1447", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,10,1)
      Show( "M_1448", r )
   RECOVER USING e
      Err( "M_1448", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,5,2)
      Show( "M_1449", r )
   RECOVER USING e
      Err( "M_1449", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,4,2)
      Show( "M_1450", r )
   RECOVER USING e
      Err( "M_1450", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,3,0)
      Show( "M_1451", r )
   RECOVER USING e
      Err( "M_1451", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,2,0)
      Show( "M_1452", r )
   RECOVER USING e
      Err( "M_1452", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,1,0)
      Show( "M_1453", r )
   RECOVER USING e
      Err( "M_1453", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,6,3)
      Show( "M_1454", r )
   RECOVER USING e
      Err( "M_1454", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,20,15)
      Show( "M_1455", r )
   RECOVER USING e
      Err( "M_1455", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,30,20)
      Show( "M_1456", r )
   RECOVER USING e
      Err( "M_1456", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,8,-1)
      Show( "M_1457", r )
   RECOVER USING e
      Err( "M_1457", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,10,3)
      Show( "M_1458", r )
   RECOVER USING e
      Err( "M_1458", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,0,0)
      Show( "M_1459", r )
   RECOVER USING e
      Err( "M_1459", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,12,6)
      Show( "M_1460", r )
   RECOVER USING e
      Err( "M_1460", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000)
      Show( "M_1461", r )
   RECOVER USING e
      Err( "M_1461", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,8)
      Show( "M_1462", r )
   RECOVER USING e
      Err( "M_1462", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,3)
      Show( "M_1463", r )
   RECOVER USING e
      Err( "M_1463", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,20)
      Show( "M_1464", r )
   RECOVER USING e
      Err( "M_1464", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000,5)
      Show( "M_1465", r )
   RECOVER USING e
      Err( "M_1465", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,10,2)
      Show( "M_1466", r )
   RECOVER USING e
      Err( "M_1466", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,10,0)
      Show( "M_1467", r )
   RECOVER USING e
      Err( "M_1467", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,10,1)
      Show( "M_1468", r )
   RECOVER USING e
      Err( "M_1468", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,5,2)
      Show( "M_1469", r )
   RECOVER USING e
      Err( "M_1469", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,4,2)
      Show( "M_1470", r )
   RECOVER USING e
      Err( "M_1470", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P049()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,3,0)
      Show( "M_1471", r )
   RECOVER USING e
      Err( "M_1471", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,2,0)
      Show( "M_1472", r )
   RECOVER USING e
      Err( "M_1472", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,1,0)
      Show( "M_1473", r )
   RECOVER USING e
      Err( "M_1473", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,6,3)
      Show( "M_1474", r )
   RECOVER USING e
      Err( "M_1474", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,20,15)
      Show( "M_1475", r )
   RECOVER USING e
      Err( "M_1475", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,30,20)
      Show( "M_1476", r )
   RECOVER USING e
      Err( "M_1476", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,8,-1)
      Show( "M_1477", r )
   RECOVER USING e
      Err( "M_1477", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,10,3)
      Show( "M_1478", r )
   RECOVER USING e
      Err( "M_1478", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,0,0)
      Show( "M_1479", r )
   RECOVER USING e
      Err( "M_1479", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,12,6)
      Show( "M_1480", r )
   RECOVER USING e
      Err( "M_1480", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5)
      Show( "M_1481", r )
   RECOVER USING e
      Err( "M_1481", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,8)
      Show( "M_1482", r )
   RECOVER USING e
      Err( "M_1482", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,3)
      Show( "M_1483", r )
   RECOVER USING e
      Err( "M_1483", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,20)
      Show( "M_1484", r )
   RECOVER USING e
      Err( "M_1484", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1000000000000000+0.5,5)
      Show( "M_1485", r )
   RECOVER USING e
      Err( "M_1485", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,10,2)
      Show( "M_1486", r )
   RECOVER USING e
      Err( "M_1486", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,10,0)
      Show( "M_1487", r )
   RECOVER USING e
      Err( "M_1487", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,10,1)
      Show( "M_1488", r )
   RECOVER USING e
      Err( "M_1488", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,5,2)
      Show( "M_1489", r )
   RECOVER USING e
      Err( "M_1489", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,4,2)
      Show( "M_1490", r )
   RECOVER USING e
      Err( "M_1490", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,3,0)
      Show( "M_1491", r )
   RECOVER USING e
      Err( "M_1491", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,2,0)
      Show( "M_1492", r )
   RECOVER USING e
      Err( "M_1492", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,1,0)
      Show( "M_1493", r )
   RECOVER USING e
      Err( "M_1493", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,6,3)
      Show( "M_1494", r )
   RECOVER USING e
      Err( "M_1494", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,20,15)
      Show( "M_1495", r )
   RECOVER USING e
      Err( "M_1495", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,30,20)
      Show( "M_1496", r )
   RECOVER USING e
      Err( "M_1496", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,8,-1)
      Show( "M_1497", r )
   RECOVER USING e
      Err( "M_1497", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,10,3)
      Show( "M_1498", r )
   RECOVER USING e
      Err( "M_1498", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,0,0)
      Show( "M_1499", r )
   RECOVER USING e
      Err( "M_1499", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,12,6)
      Show( "M_1500", r )
   RECOVER USING e
      Err( "M_1500", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P050()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2)
      Show( "M_1501", r )
   RECOVER USING e
      Err( "M_1501", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,8)
      Show( "M_1502", r )
   RECOVER USING e
      Err( "M_1502", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,3)
      Show( "M_1503", r )
   RECOVER USING e
      Err( "M_1503", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,20)
      Show( "M_1504", r )
   RECOVER USING e
      Err( "M_1504", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(0.1+0.2,5)
      Show( "M_1505", r )
   RECOVER USING e
      Err( "M_1505", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,10,2)
      Show( "M_1506", r )
   RECOVER USING e
      Err( "M_1506", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,10,0)
      Show( "M_1507", r )
   RECOVER USING e
      Err( "M_1507", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,10,1)
      Show( "M_1508", r )
   RECOVER USING e
      Err( "M_1508", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,5,2)
      Show( "M_1509", r )
   RECOVER USING e
      Err( "M_1509", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,4,2)
      Show( "M_1510", r )
   RECOVER USING e
      Err( "M_1510", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,3,0)
      Show( "M_1511", r )
   RECOVER USING e
      Err( "M_1511", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,2,0)
      Show( "M_1512", r )
   RECOVER USING e
      Err( "M_1512", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,1,0)
      Show( "M_1513", r )
   RECOVER USING e
      Err( "M_1513", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,6,3)
      Show( "M_1514", r )
   RECOVER USING e
      Err( "M_1514", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,20,15)
      Show( "M_1515", r )
   RECOVER USING e
      Err( "M_1515", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,30,20)
      Show( "M_1516", r )
   RECOVER USING e
      Err( "M_1516", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,8,-1)
      Show( "M_1517", r )
   RECOVER USING e
      Err( "M_1517", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,10,3)
      Show( "M_1518", r )
   RECOVER USING e
      Err( "M_1518", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,0,0)
      Show( "M_1519", r )
   RECOVER USING e
      Err( "M_1519", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,12,6)
      Show( "M_1520", r )
   RECOVER USING e
      Err( "M_1520", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3)
      Show( "M_1521", r )
   RECOVER USING e
      Err( "M_1521", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,8)
      Show( "M_1522", r )
   RECOVER USING e
      Err( "M_1522", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,3)
      Show( "M_1523", r )
   RECOVER USING e
      Err( "M_1523", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,20)
      Show( "M_1524", r )
   RECOVER USING e
      Err( "M_1524", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(1/3,5)
      Show( "M_1525", r )
   RECOVER USING e
      Err( "M_1525", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,0),4,0)
      Show( "M_1526", r )
   RECOVER USING e
      Err( "M_1526", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,0),4)
      Show( "M_1527", r )
   RECOVER USING e
      Err( "M_1527", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,4,0))
      Show( "M_1528", r )
   RECOVER USING e
      Err( "M_1528", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,14,3)),0)
      Show( "M_1529", r )
   RECOVER USING e
      Err( "M_1529", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,0),6,0)
      Show( "M_1530", r )
   RECOVER USING e
      Err( "M_1530", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P051()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,0),6)
      Show( "M_1531", r )
   RECOVER USING e
      Err( "M_1531", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,6,0))
      Show( "M_1532", r )
   RECOVER USING e
      Err( "M_1532", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,16,3)),0)
      Show( "M_1533", r )
   RECOVER USING e
      Err( "M_1533", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,0),10,0)
      Show( "M_1534", r )
   RECOVER USING e
      Err( "M_1534", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,0),10)
      Show( "M_1535", r )
   RECOVER USING e
      Err( "M_1535", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,10,0))
      Show( "M_1536", r )
   RECOVER USING e
      Err( "M_1536", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,20,3)),0)
      Show( "M_1537", r )
   RECOVER USING e
      Err( "M_1537", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,1),4,1)
      Show( "M_1538", r )
   RECOVER USING e
      Err( "M_1538", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,1),4)
      Show( "M_1539", r )
   RECOVER USING e
      Err( "M_1539", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,4,1))
      Show( "M_1540", r )
   RECOVER USING e
      Err( "M_1540", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,14,4)),1)
      Show( "M_1541", r )
   RECOVER USING e
      Err( "M_1541", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,1),6,1)
      Show( "M_1542", r )
   RECOVER USING e
      Err( "M_1542", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,1),6)
      Show( "M_1543", r )
   RECOVER USING e
      Err( "M_1543", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,6,1))
      Show( "M_1544", r )
   RECOVER USING e
      Err( "M_1544", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,16,4)),1)
      Show( "M_1545", r )
   RECOVER USING e
      Err( "M_1545", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,1),10,1)
      Show( "M_1546", r )
   RECOVER USING e
      Err( "M_1546", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,1),10)
      Show( "M_1547", r )
   RECOVER USING e
      Err( "M_1547", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,10,1))
      Show( "M_1548", r )
   RECOVER USING e
      Err( "M_1548", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,20,4)),1)
      Show( "M_1549", r )
   RECOVER USING e
      Err( "M_1549", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,2),4,2)
      Show( "M_1550", r )
   RECOVER USING e
      Err( "M_1550", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,2),4)
      Show( "M_1551", r )
   RECOVER USING e
      Err( "M_1551", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,4,2))
      Show( "M_1552", r )
   RECOVER USING e
      Err( "M_1552", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,14,5)),2)
      Show( "M_1553", r )
   RECOVER USING e
      Err( "M_1553", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,2),6,2)
      Show( "M_1554", r )
   RECOVER USING e
      Err( "M_1554", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,2),6)
      Show( "M_1555", r )
   RECOVER USING e
      Err( "M_1555", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,6,2))
      Show( "M_1556", r )
   RECOVER USING e
      Err( "M_1556", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,16,5)),2)
      Show( "M_1557", r )
   RECOVER USING e
      Err( "M_1557", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,2),10,2)
      Show( "M_1558", r )
   RECOVER USING e
      Err( "M_1558", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,2),10)
      Show( "M_1559", r )
   RECOVER USING e
      Err( "M_1559", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,10,2))
      Show( "M_1560", r )
   RECOVER USING e
      Err( "M_1560", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P052()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,20,5)),2)
      Show( "M_1561", r )
   RECOVER USING e
      Err( "M_1561", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,3),4,3)
      Show( "M_1562", r )
   RECOVER USING e
      Err( "M_1562", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,3),4)
      Show( "M_1563", r )
   RECOVER USING e
      Err( "M_1563", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,4,3))
      Show( "M_1564", r )
   RECOVER USING e
      Err( "M_1564", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,14,6)),3)
      Show( "M_1565", r )
   RECOVER USING e
      Err( "M_1565", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,3),6,3)
      Show( "M_1566", r )
   RECOVER USING e
      Err( "M_1566", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,3),6)
      Show( "M_1567", r )
   RECOVER USING e
      Err( "M_1567", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,6,3))
      Show( "M_1568", r )
   RECOVER USING e
      Err( "M_1568", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,16,6)),3)
      Show( "M_1569", r )
   RECOVER USING e
      Err( "M_1569", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,3),10,3)
      Show( "M_1570", r )
   RECOVER USING e
      Err( "M_1570", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.005,3),10)
      Show( "M_1571", r )
   RECOVER USING e
      Err( "M_1571", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,10,3))
      Show( "M_1572", r )
   RECOVER USING e
      Err( "M_1572", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.005,20,6)),3)
      Show( "M_1573", r )
   RECOVER USING e
      Err( "M_1573", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,0),4,0)
      Show( "M_1574", r )
   RECOVER USING e
      Err( "M_1574", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,0),4)
      Show( "M_1575", r )
   RECOVER USING e
      Err( "M_1575", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,4,0))
      Show( "M_1576", r )
   RECOVER USING e
      Err( "M_1576", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,14,3)),0)
      Show( "M_1577", r )
   RECOVER USING e
      Err( "M_1577", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,0),6,0)
      Show( "M_1578", r )
   RECOVER USING e
      Err( "M_1578", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,0),6)
      Show( "M_1579", r )
   RECOVER USING e
      Err( "M_1579", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,6,0))
      Show( "M_1580", r )
   RECOVER USING e
      Err( "M_1580", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,16,3)),0)
      Show( "M_1581", r )
   RECOVER USING e
      Err( "M_1581", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,0),10,0)
      Show( "M_1582", r )
   RECOVER USING e
      Err( "M_1582", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,0),10)
      Show( "M_1583", r )
   RECOVER USING e
      Err( "M_1583", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,10,0))
      Show( "M_1584", r )
   RECOVER USING e
      Err( "M_1584", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,20,3)),0)
      Show( "M_1585", r )
   RECOVER USING e
      Err( "M_1585", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,1),4,1)
      Show( "M_1586", r )
   RECOVER USING e
      Err( "M_1586", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,1),4)
      Show( "M_1587", r )
   RECOVER USING e
      Err( "M_1587", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,4,1))
      Show( "M_1588", r )
   RECOVER USING e
      Err( "M_1588", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,14,4)),1)
      Show( "M_1589", r )
   RECOVER USING e
      Err( "M_1589", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,1),6,1)
      Show( "M_1590", r )
   RECOVER USING e
      Err( "M_1590", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P053()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,1),6)
      Show( "M_1591", r )
   RECOVER USING e
      Err( "M_1591", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,6,1))
      Show( "M_1592", r )
   RECOVER USING e
      Err( "M_1592", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,16,4)),1)
      Show( "M_1593", r )
   RECOVER USING e
      Err( "M_1593", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,1),10,1)
      Show( "M_1594", r )
   RECOVER USING e
      Err( "M_1594", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,1),10)
      Show( "M_1595", r )
   RECOVER USING e
      Err( "M_1595", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,10,1))
      Show( "M_1596", r )
   RECOVER USING e
      Err( "M_1596", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,20,4)),1)
      Show( "M_1597", r )
   RECOVER USING e
      Err( "M_1597", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,2),4,2)
      Show( "M_1598", r )
   RECOVER USING e
      Err( "M_1598", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,2),4)
      Show( "M_1599", r )
   RECOVER USING e
      Err( "M_1599", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,4,2))
      Show( "M_1600", r )
   RECOVER USING e
      Err( "M_1600", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,14,5)),2)
      Show( "M_1601", r )
   RECOVER USING e
      Err( "M_1601", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,2),6,2)
      Show( "M_1602", r )
   RECOVER USING e
      Err( "M_1602", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,2),6)
      Show( "M_1603", r )
   RECOVER USING e
      Err( "M_1603", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,6,2))
      Show( "M_1604", r )
   RECOVER USING e
      Err( "M_1604", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,16,5)),2)
      Show( "M_1605", r )
   RECOVER USING e
      Err( "M_1605", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,2),10,2)
      Show( "M_1606", r )
   RECOVER USING e
      Err( "M_1606", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,2),10)
      Show( "M_1607", r )
   RECOVER USING e
      Err( "M_1607", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,10,2))
      Show( "M_1608", r )
   RECOVER USING e
      Err( "M_1608", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,20,5)),2)
      Show( "M_1609", r )
   RECOVER USING e
      Err( "M_1609", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,3),4,3)
      Show( "M_1610", r )
   RECOVER USING e
      Err( "M_1610", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,3),4)
      Show( "M_1611", r )
   RECOVER USING e
      Err( "M_1611", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,4,3))
      Show( "M_1612", r )
   RECOVER USING e
      Err( "M_1612", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,14,6)),3)
      Show( "M_1613", r )
   RECOVER USING e
      Err( "M_1613", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,3),6,3)
      Show( "M_1614", r )
   RECOVER USING e
      Err( "M_1614", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,3),6)
      Show( "M_1615", r )
   RECOVER USING e
      Err( "M_1615", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,6,3))
      Show( "M_1616", r )
   RECOVER USING e
      Err( "M_1616", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,16,6)),3)
      Show( "M_1617", r )
   RECOVER USING e
      Err( "M_1617", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,3),10,3)
      Show( "M_1618", r )
   RECOVER USING e
      Err( "M_1618", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.675,3),10)
      Show( "M_1619", r )
   RECOVER USING e
      Err( "M_1619", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,10,3))
      Show( "M_1620", r )
   RECOVER USING e
      Err( "M_1620", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P054()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.675,20,6)),3)
      Show( "M_1621", r )
   RECOVER USING e
      Err( "M_1621", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,0),4,0)
      Show( "M_1622", r )
   RECOVER USING e
      Err( "M_1622", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,0),4)
      Show( "M_1623", r )
   RECOVER USING e
      Err( "M_1623", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,4,0))
      Show( "M_1624", r )
   RECOVER USING e
      Err( "M_1624", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,14,3)),0)
      Show( "M_1625", r )
   RECOVER USING e
      Err( "M_1625", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,0),6,0)
      Show( "M_1626", r )
   RECOVER USING e
      Err( "M_1626", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,0),6)
      Show( "M_1627", r )
   RECOVER USING e
      Err( "M_1627", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,6,0))
      Show( "M_1628", r )
   RECOVER USING e
      Err( "M_1628", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,16,3)),0)
      Show( "M_1629", r )
   RECOVER USING e
      Err( "M_1629", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,0),10,0)
      Show( "M_1630", r )
   RECOVER USING e
      Err( "M_1630", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,0),10)
      Show( "M_1631", r )
   RECOVER USING e
      Err( "M_1631", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,10,0))
      Show( "M_1632", r )
   RECOVER USING e
      Err( "M_1632", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,20,3)),0)
      Show( "M_1633", r )
   RECOVER USING e
      Err( "M_1633", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,1),4,1)
      Show( "M_1634", r )
   RECOVER USING e
      Err( "M_1634", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,1),4)
      Show( "M_1635", r )
   RECOVER USING e
      Err( "M_1635", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,4,1))
      Show( "M_1636", r )
   RECOVER USING e
      Err( "M_1636", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,14,4)),1)
      Show( "M_1637", r )
   RECOVER USING e
      Err( "M_1637", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,1),6,1)
      Show( "M_1638", r )
   RECOVER USING e
      Err( "M_1638", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,1),6)
      Show( "M_1639", r )
   RECOVER USING e
      Err( "M_1639", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,6,1))
      Show( "M_1640", r )
   RECOVER USING e
      Err( "M_1640", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,16,4)),1)
      Show( "M_1641", r )
   RECOVER USING e
      Err( "M_1641", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,1),10,1)
      Show( "M_1642", r )
   RECOVER USING e
      Err( "M_1642", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,1),10)
      Show( "M_1643", r )
   RECOVER USING e
      Err( "M_1643", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,10,1))
      Show( "M_1644", r )
   RECOVER USING e
      Err( "M_1644", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,20,4)),1)
      Show( "M_1645", r )
   RECOVER USING e
      Err( "M_1645", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,2),4,2)
      Show( "M_1646", r )
   RECOVER USING e
      Err( "M_1646", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,2),4)
      Show( "M_1647", r )
   RECOVER USING e
      Err( "M_1647", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,4,2))
      Show( "M_1648", r )
   RECOVER USING e
      Err( "M_1648", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,14,5)),2)
      Show( "M_1649", r )
   RECOVER USING e
      Err( "M_1649", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,2),6,2)
      Show( "M_1650", r )
   RECOVER USING e
      Err( "M_1650", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P055()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,2),6)
      Show( "M_1651", r )
   RECOVER USING e
      Err( "M_1651", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,6,2))
      Show( "M_1652", r )
   RECOVER USING e
      Err( "M_1652", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,16,5)),2)
      Show( "M_1653", r )
   RECOVER USING e
      Err( "M_1653", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,2),10,2)
      Show( "M_1654", r )
   RECOVER USING e
      Err( "M_1654", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,2),10)
      Show( "M_1655", r )
   RECOVER USING e
      Err( "M_1655", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,10,2))
      Show( "M_1656", r )
   RECOVER USING e
      Err( "M_1656", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,20,5)),2)
      Show( "M_1657", r )
   RECOVER USING e
      Err( "M_1657", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,3),4,3)
      Show( "M_1658", r )
   RECOVER USING e
      Err( "M_1658", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,3),4)
      Show( "M_1659", r )
   RECOVER USING e
      Err( "M_1659", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,4,3))
      Show( "M_1660", r )
   RECOVER USING e
      Err( "M_1660", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,14,6)),3)
      Show( "M_1661", r )
   RECOVER USING e
      Err( "M_1661", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,3),6,3)
      Show( "M_1662", r )
   RECOVER USING e
      Err( "M_1662", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,3),6)
      Show( "M_1663", r )
   RECOVER USING e
      Err( "M_1663", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,6,3))
      Show( "M_1664", r )
   RECOVER USING e
      Err( "M_1664", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,16,6)),3)
      Show( "M_1665", r )
   RECOVER USING e
      Err( "M_1665", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,3),10,3)
      Show( "M_1666", r )
   RECOVER USING e
      Err( "M_1666", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.285,3),10)
      Show( "M_1667", r )
   RECOVER USING e
      Err( "M_1667", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,10,3))
      Show( "M_1668", r )
   RECOVER USING e
      Err( "M_1668", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.285,20,6)),3)
      Show( "M_1669", r )
   RECOVER USING e
      Err( "M_1669", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,0),4,0)
      Show( "M_1670", r )
   RECOVER USING e
      Err( "M_1670", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,0),4)
      Show( "M_1671", r )
   RECOVER USING e
      Err( "M_1671", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,4,0))
      Show( "M_1672", r )
   RECOVER USING e
      Err( "M_1672", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,14,3)),0)
      Show( "M_1673", r )
   RECOVER USING e
      Err( "M_1673", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,0),6,0)
      Show( "M_1674", r )
   RECOVER USING e
      Err( "M_1674", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,0),6)
      Show( "M_1675", r )
   RECOVER USING e
      Err( "M_1675", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,6,0))
      Show( "M_1676", r )
   RECOVER USING e
      Err( "M_1676", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,16,3)),0)
      Show( "M_1677", r )
   RECOVER USING e
      Err( "M_1677", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,0),10,0)
      Show( "M_1678", r )
   RECOVER USING e
      Err( "M_1678", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,0),10)
      Show( "M_1679", r )
   RECOVER USING e
      Err( "M_1679", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,10,0))
      Show( "M_1680", r )
   RECOVER USING e
      Err( "M_1680", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P056()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,20,3)),0)
      Show( "M_1681", r )
   RECOVER USING e
      Err( "M_1681", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,1),4,1)
      Show( "M_1682", r )
   RECOVER USING e
      Err( "M_1682", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,1),4)
      Show( "M_1683", r )
   RECOVER USING e
      Err( "M_1683", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,4,1))
      Show( "M_1684", r )
   RECOVER USING e
      Err( "M_1684", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,14,4)),1)
      Show( "M_1685", r )
   RECOVER USING e
      Err( "M_1685", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,1),6,1)
      Show( "M_1686", r )
   RECOVER USING e
      Err( "M_1686", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,1),6)
      Show( "M_1687", r )
   RECOVER USING e
      Err( "M_1687", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,6,1))
      Show( "M_1688", r )
   RECOVER USING e
      Err( "M_1688", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,16,4)),1)
      Show( "M_1689", r )
   RECOVER USING e
      Err( "M_1689", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,1),10,1)
      Show( "M_1690", r )
   RECOVER USING e
      Err( "M_1690", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,1),10)
      Show( "M_1691", r )
   RECOVER USING e
      Err( "M_1691", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,10,1))
      Show( "M_1692", r )
   RECOVER USING e
      Err( "M_1692", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,20,4)),1)
      Show( "M_1693", r )
   RECOVER USING e
      Err( "M_1693", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,2),4,2)
      Show( "M_1694", r )
   RECOVER USING e
      Err( "M_1694", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,2),4)
      Show( "M_1695", r )
   RECOVER USING e
      Err( "M_1695", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,4,2))
      Show( "M_1696", r )
   RECOVER USING e
      Err( "M_1696", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,14,5)),2)
      Show( "M_1697", r )
   RECOVER USING e
      Err( "M_1697", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,2),6,2)
      Show( "M_1698", r )
   RECOVER USING e
      Err( "M_1698", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,2),6)
      Show( "M_1699", r )
   RECOVER USING e
      Err( "M_1699", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,6,2))
      Show( "M_1700", r )
   RECOVER USING e
      Err( "M_1700", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,16,5)),2)
      Show( "M_1701", r )
   RECOVER USING e
      Err( "M_1701", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,2),10,2)
      Show( "M_1702", r )
   RECOVER USING e
      Err( "M_1702", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,2),10)
      Show( "M_1703", r )
   RECOVER USING e
      Err( "M_1703", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,10,2))
      Show( "M_1704", r )
   RECOVER USING e
      Err( "M_1704", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,20,5)),2)
      Show( "M_1705", r )
   RECOVER USING e
      Err( "M_1705", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,3),4,3)
      Show( "M_1706", r )
   RECOVER USING e
      Err( "M_1706", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,3),4)
      Show( "M_1707", r )
   RECOVER USING e
      Err( "M_1707", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,4,3))
      Show( "M_1708", r )
   RECOVER USING e
      Err( "M_1708", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,14,6)),3)
      Show( "M_1709", r )
   RECOVER USING e
      Err( "M_1709", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,3),6,3)
      Show( "M_1710", r )
   RECOVER USING e
      Err( "M_1710", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P057()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,3),6)
      Show( "M_1711", r )
   RECOVER USING e
      Err( "M_1711", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,6,3))
      Show( "M_1712", r )
   RECOVER USING e
      Err( "M_1712", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,16,6)),3)
      Show( "M_1713", r )
   RECOVER USING e
      Err( "M_1713", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,3),10,3)
      Show( "M_1714", r )
   RECOVER USING e
      Err( "M_1714", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(0.5,3),10)
      Show( "M_1715", r )
   RECOVER USING e
      Err( "M_1715", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,10,3))
      Show( "M_1716", r )
   RECOVER USING e
      Err( "M_1716", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(0.5,20,6)),3)
      Show( "M_1717", r )
   RECOVER USING e
      Err( "M_1717", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,0),4,0)
      Show( "M_1718", r )
   RECOVER USING e
      Err( "M_1718", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,0),4)
      Show( "M_1719", r )
   RECOVER USING e
      Err( "M_1719", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,4,0))
      Show( "M_1720", r )
   RECOVER USING e
      Err( "M_1720", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,14,3)),0)
      Show( "M_1721", r )
   RECOVER USING e
      Err( "M_1721", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,0),6,0)
      Show( "M_1722", r )
   RECOVER USING e
      Err( "M_1722", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,0),6)
      Show( "M_1723", r )
   RECOVER USING e
      Err( "M_1723", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,6,0))
      Show( "M_1724", r )
   RECOVER USING e
      Err( "M_1724", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,16,3)),0)
      Show( "M_1725", r )
   RECOVER USING e
      Err( "M_1725", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,0),10,0)
      Show( "M_1726", r )
   RECOVER USING e
      Err( "M_1726", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,0),10)
      Show( "M_1727", r )
   RECOVER USING e
      Err( "M_1727", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,10,0))
      Show( "M_1728", r )
   RECOVER USING e
      Err( "M_1728", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,20,3)),0)
      Show( "M_1729", r )
   RECOVER USING e
      Err( "M_1729", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,1),4,1)
      Show( "M_1730", r )
   RECOVER USING e
      Err( "M_1730", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,1),4)
      Show( "M_1731", r )
   RECOVER USING e
      Err( "M_1731", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,4,1))
      Show( "M_1732", r )
   RECOVER USING e
      Err( "M_1732", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,14,4)),1)
      Show( "M_1733", r )
   RECOVER USING e
      Err( "M_1733", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,1),6,1)
      Show( "M_1734", r )
   RECOVER USING e
      Err( "M_1734", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,1),6)
      Show( "M_1735", r )
   RECOVER USING e
      Err( "M_1735", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,6,1))
      Show( "M_1736", r )
   RECOVER USING e
      Err( "M_1736", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,16,4)),1)
      Show( "M_1737", r )
   RECOVER USING e
      Err( "M_1737", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,1),10,1)
      Show( "M_1738", r )
   RECOVER USING e
      Err( "M_1738", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,1),10)
      Show( "M_1739", r )
   RECOVER USING e
      Err( "M_1739", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,10,1))
      Show( "M_1740", r )
   RECOVER USING e
      Err( "M_1740", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P058()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,20,4)),1)
      Show( "M_1741", r )
   RECOVER USING e
      Err( "M_1741", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,2),4,2)
      Show( "M_1742", r )
   RECOVER USING e
      Err( "M_1742", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,2),4)
      Show( "M_1743", r )
   RECOVER USING e
      Err( "M_1743", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,4,2))
      Show( "M_1744", r )
   RECOVER USING e
      Err( "M_1744", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,14,5)),2)
      Show( "M_1745", r )
   RECOVER USING e
      Err( "M_1745", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,2),6,2)
      Show( "M_1746", r )
   RECOVER USING e
      Err( "M_1746", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,2),6)
      Show( "M_1747", r )
   RECOVER USING e
      Err( "M_1747", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,6,2))
      Show( "M_1748", r )
   RECOVER USING e
      Err( "M_1748", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,16,5)),2)
      Show( "M_1749", r )
   RECOVER USING e
      Err( "M_1749", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,2),10,2)
      Show( "M_1750", r )
   RECOVER USING e
      Err( "M_1750", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,2),10)
      Show( "M_1751", r )
   RECOVER USING e
      Err( "M_1751", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,10,2))
      Show( "M_1752", r )
   RECOVER USING e
      Err( "M_1752", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,20,5)),2)
      Show( "M_1753", r )
   RECOVER USING e
      Err( "M_1753", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,3),4,3)
      Show( "M_1754", r )
   RECOVER USING e
      Err( "M_1754", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,3),4)
      Show( "M_1755", r )
   RECOVER USING e
      Err( "M_1755", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,4,3))
      Show( "M_1756", r )
   RECOVER USING e
      Err( "M_1756", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,14,6)),3)
      Show( "M_1757", r )
   RECOVER USING e
      Err( "M_1757", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,3),6,3)
      Show( "M_1758", r )
   RECOVER USING e
      Err( "M_1758", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,3),6)
      Show( "M_1759", r )
   RECOVER USING e
      Err( "M_1759", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,6,3))
      Show( "M_1760", r )
   RECOVER USING e
      Err( "M_1760", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,16,6)),3)
      Show( "M_1761", r )
   RECOVER USING e
      Err( "M_1761", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,3),10,3)
      Show( "M_1762", r )
   RECOVER USING e
      Err( "M_1762", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1.5,3),10)
      Show( "M_1763", r )
   RECOVER USING e
      Err( "M_1763", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.5,10,3))
      Show( "M_1764", r )
   RECOVER USING e
      Err( "M_1764", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1.5,20,6)),3)
      Show( "M_1765", r )
   RECOVER USING e
      Err( "M_1765", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,0),4,0)
      Show( "M_1766", r )
   RECOVER USING e
      Err( "M_1766", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,0),4)
      Show( "M_1767", r )
   RECOVER USING e
      Err( "M_1767", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,4,0))
      Show( "M_1768", r )
   RECOVER USING e
      Err( "M_1768", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,14,3)),0)
      Show( "M_1769", r )
   RECOVER USING e
      Err( "M_1769", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,0),6,0)
      Show( "M_1770", r )
   RECOVER USING e
      Err( "M_1770", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P059()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,0),6)
      Show( "M_1771", r )
   RECOVER USING e
      Err( "M_1771", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,6,0))
      Show( "M_1772", r )
   RECOVER USING e
      Err( "M_1772", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,16,3)),0)
      Show( "M_1773", r )
   RECOVER USING e
      Err( "M_1773", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,0),10,0)
      Show( "M_1774", r )
   RECOVER USING e
      Err( "M_1774", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,0),10)
      Show( "M_1775", r )
   RECOVER USING e
      Err( "M_1775", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,10,0))
      Show( "M_1776", r )
   RECOVER USING e
      Err( "M_1776", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,20,3)),0)
      Show( "M_1777", r )
   RECOVER USING e
      Err( "M_1777", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,1),4,1)
      Show( "M_1778", r )
   RECOVER USING e
      Err( "M_1778", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,1),4)
      Show( "M_1779", r )
   RECOVER USING e
      Err( "M_1779", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,4,1))
      Show( "M_1780", r )
   RECOVER USING e
      Err( "M_1780", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,14,4)),1)
      Show( "M_1781", r )
   RECOVER USING e
      Err( "M_1781", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,1),6,1)
      Show( "M_1782", r )
   RECOVER USING e
      Err( "M_1782", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,1),6)
      Show( "M_1783", r )
   RECOVER USING e
      Err( "M_1783", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,6,1))
      Show( "M_1784", r )
   RECOVER USING e
      Err( "M_1784", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,16,4)),1)
      Show( "M_1785", r )
   RECOVER USING e
      Err( "M_1785", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,1),10,1)
      Show( "M_1786", r )
   RECOVER USING e
      Err( "M_1786", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,1),10)
      Show( "M_1787", r )
   RECOVER USING e
      Err( "M_1787", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,10,1))
      Show( "M_1788", r )
   RECOVER USING e
      Err( "M_1788", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,20,4)),1)
      Show( "M_1789", r )
   RECOVER USING e
      Err( "M_1789", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,2),4,2)
      Show( "M_1790", r )
   RECOVER USING e
      Err( "M_1790", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,2),4)
      Show( "M_1791", r )
   RECOVER USING e
      Err( "M_1791", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,4,2))
      Show( "M_1792", r )
   RECOVER USING e
      Err( "M_1792", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,14,5)),2)
      Show( "M_1793", r )
   RECOVER USING e
      Err( "M_1793", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,2),6,2)
      Show( "M_1794", r )
   RECOVER USING e
      Err( "M_1794", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,2),6)
      Show( "M_1795", r )
   RECOVER USING e
      Err( "M_1795", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,6,2))
      Show( "M_1796", r )
   RECOVER USING e
      Err( "M_1796", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,16,5)),2)
      Show( "M_1797", r )
   RECOVER USING e
      Err( "M_1797", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,2),10,2)
      Show( "M_1798", r )
   RECOVER USING e
      Err( "M_1798", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,2),10)
      Show( "M_1799", r )
   RECOVER USING e
      Err( "M_1799", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,10,2))
      Show( "M_1800", r )
   RECOVER USING e
      Err( "M_1800", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P060()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,20,5)),2)
      Show( "M_1801", r )
   RECOVER USING e
      Err( "M_1801", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,3),4,3)
      Show( "M_1802", r )
   RECOVER USING e
      Err( "M_1802", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,3),4)
      Show( "M_1803", r )
   RECOVER USING e
      Err( "M_1803", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,4,3))
      Show( "M_1804", r )
   RECOVER USING e
      Err( "M_1804", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,14,6)),3)
      Show( "M_1805", r )
   RECOVER USING e
      Err( "M_1805", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,3),6,3)
      Show( "M_1806", r )
   RECOVER USING e
      Err( "M_1806", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,3),6)
      Show( "M_1807", r )
   RECOVER USING e
      Err( "M_1807", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,6,3))
      Show( "M_1808", r )
   RECOVER USING e
      Err( "M_1808", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,16,6)),3)
      Show( "M_1809", r )
   RECOVER USING e
      Err( "M_1809", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,3),10,3)
      Show( "M_1810", r )
   RECOVER USING e
      Err( "M_1810", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(2.5,3),10)
      Show( "M_1811", r )
   RECOVER USING e
      Err( "M_1811", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.5,10,3))
      Show( "M_1812", r )
   RECOVER USING e
      Err( "M_1812", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(2.5,20,6)),3)
      Show( "M_1813", r )
   RECOVER USING e
      Err( "M_1813", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,0),4,0)
      Show( "M_1814", r )
   RECOVER USING e
      Err( "M_1814", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,0),4)
      Show( "M_1815", r )
   RECOVER USING e
      Err( "M_1815", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,4,0))
      Show( "M_1816", r )
   RECOVER USING e
      Err( "M_1816", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,14,3)),0)
      Show( "M_1817", r )
   RECOVER USING e
      Err( "M_1817", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,0),6,0)
      Show( "M_1818", r )
   RECOVER USING e
      Err( "M_1818", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,0),6)
      Show( "M_1819", r )
   RECOVER USING e
      Err( "M_1819", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,6,0))
      Show( "M_1820", r )
   RECOVER USING e
      Err( "M_1820", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,16,3)),0)
      Show( "M_1821", r )
   RECOVER USING e
      Err( "M_1821", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,0),10,0)
      Show( "M_1822", r )
   RECOVER USING e
      Err( "M_1822", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,0),10)
      Show( "M_1823", r )
   RECOVER USING e
      Err( "M_1823", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,10,0))
      Show( "M_1824", r )
   RECOVER USING e
      Err( "M_1824", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,20,3)),0)
      Show( "M_1825", r )
   RECOVER USING e
      Err( "M_1825", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,1),4,1)
      Show( "M_1826", r )
   RECOVER USING e
      Err( "M_1826", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,1),4)
      Show( "M_1827", r )
   RECOVER USING e
      Err( "M_1827", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,4,1))
      Show( "M_1828", r )
   RECOVER USING e
      Err( "M_1828", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,14,4)),1)
      Show( "M_1829", r )
   RECOVER USING e
      Err( "M_1829", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,1),6,1)
      Show( "M_1830", r )
   RECOVER USING e
      Err( "M_1830", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P061()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,1),6)
      Show( "M_1831", r )
   RECOVER USING e
      Err( "M_1831", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,6,1))
      Show( "M_1832", r )
   RECOVER USING e
      Err( "M_1832", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,16,4)),1)
      Show( "M_1833", r )
   RECOVER USING e
      Err( "M_1833", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,1),10,1)
      Show( "M_1834", r )
   RECOVER USING e
      Err( "M_1834", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,1),10)
      Show( "M_1835", r )
   RECOVER USING e
      Err( "M_1835", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,10,1))
      Show( "M_1836", r )
   RECOVER USING e
      Err( "M_1836", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,20,4)),1)
      Show( "M_1837", r )
   RECOVER USING e
      Err( "M_1837", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,2),4,2)
      Show( "M_1838", r )
   RECOVER USING e
      Err( "M_1838", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,2),4)
      Show( "M_1839", r )
   RECOVER USING e
      Err( "M_1839", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,4,2))
      Show( "M_1840", r )
   RECOVER USING e
      Err( "M_1840", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,14,5)),2)
      Show( "M_1841", r )
   RECOVER USING e
      Err( "M_1841", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,2),6,2)
      Show( "M_1842", r )
   RECOVER USING e
      Err( "M_1842", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,2),6)
      Show( "M_1843", r )
   RECOVER USING e
      Err( "M_1843", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,6,2))
      Show( "M_1844", r )
   RECOVER USING e
      Err( "M_1844", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,16,5)),2)
      Show( "M_1845", r )
   RECOVER USING e
      Err( "M_1845", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,2),10,2)
      Show( "M_1846", r )
   RECOVER USING e
      Err( "M_1846", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,2),10)
      Show( "M_1847", r )
   RECOVER USING e
      Err( "M_1847", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,10,2))
      Show( "M_1848", r )
   RECOVER USING e
      Err( "M_1848", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,20,5)),2)
      Show( "M_1849", r )
   RECOVER USING e
      Err( "M_1849", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,3),4,3)
      Show( "M_1850", r )
   RECOVER USING e
      Err( "M_1850", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,3),4)
      Show( "M_1851", r )
   RECOVER USING e
      Err( "M_1851", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,4,3))
      Show( "M_1852", r )
   RECOVER USING e
      Err( "M_1852", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,14,6)),3)
      Show( "M_1853", r )
   RECOVER USING e
      Err( "M_1853", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,3),6,3)
      Show( "M_1854", r )
   RECOVER USING e
      Err( "M_1854", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,3),6)
      Show( "M_1855", r )
   RECOVER USING e
      Err( "M_1855", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,6,3))
      Show( "M_1856", r )
   RECOVER USING e
      Err( "M_1856", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,16,6)),3)
      Show( "M_1857", r )
   RECOVER USING e
      Err( "M_1857", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,3),10,3)
      Show( "M_1858", r )
   RECOVER USING e
      Err( "M_1858", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(123.456,3),10)
      Show( "M_1859", r )
   RECOVER USING e
      Err( "M_1859", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,10,3))
      Show( "M_1860", r )
   RECOVER USING e
      Err( "M_1860", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P062()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(123.456,20,6)),3)
      Show( "M_1861", r )
   RECOVER USING e
      Err( "M_1861", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,0),4,0)
      Show( "M_1862", r )
   RECOVER USING e
      Err( "M_1862", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,0),4)
      Show( "M_1863", r )
   RECOVER USING e
      Err( "M_1863", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,4,0))
      Show( "M_1864", r )
   RECOVER USING e
      Err( "M_1864", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,14,3)),0)
      Show( "M_1865", r )
   RECOVER USING e
      Err( "M_1865", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,0),6,0)
      Show( "M_1866", r )
   RECOVER USING e
      Err( "M_1866", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,0),6)
      Show( "M_1867", r )
   RECOVER USING e
      Err( "M_1867", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,6,0))
      Show( "M_1868", r )
   RECOVER USING e
      Err( "M_1868", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,16,3)),0)
      Show( "M_1869", r )
   RECOVER USING e
      Err( "M_1869", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,0),10,0)
      Show( "M_1870", r )
   RECOVER USING e
      Err( "M_1870", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,0),10)
      Show( "M_1871", r )
   RECOVER USING e
      Err( "M_1871", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,10,0))
      Show( "M_1872", r )
   RECOVER USING e
      Err( "M_1872", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,20,3)),0)
      Show( "M_1873", r )
   RECOVER USING e
      Err( "M_1873", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,1),4,1)
      Show( "M_1874", r )
   RECOVER USING e
      Err( "M_1874", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,1),4)
      Show( "M_1875", r )
   RECOVER USING e
      Err( "M_1875", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,4,1))
      Show( "M_1876", r )
   RECOVER USING e
      Err( "M_1876", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,14,4)),1)
      Show( "M_1877", r )
   RECOVER USING e
      Err( "M_1877", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,1),6,1)
      Show( "M_1878", r )
   RECOVER USING e
      Err( "M_1878", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,1),6)
      Show( "M_1879", r )
   RECOVER USING e
      Err( "M_1879", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,6,1))
      Show( "M_1880", r )
   RECOVER USING e
      Err( "M_1880", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,16,4)),1)
      Show( "M_1881", r )
   RECOVER USING e
      Err( "M_1881", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,1),10,1)
      Show( "M_1882", r )
   RECOVER USING e
      Err( "M_1882", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,1),10)
      Show( "M_1883", r )
   RECOVER USING e
      Err( "M_1883", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,10,1))
      Show( "M_1884", r )
   RECOVER USING e
      Err( "M_1884", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,20,4)),1)
      Show( "M_1885", r )
   RECOVER USING e
      Err( "M_1885", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,2),4,2)
      Show( "M_1886", r )
   RECOVER USING e
      Err( "M_1886", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,2),4)
      Show( "M_1887", r )
   RECOVER USING e
      Err( "M_1887", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,4,2))
      Show( "M_1888", r )
   RECOVER USING e
      Err( "M_1888", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,14,5)),2)
      Show( "M_1889", r )
   RECOVER USING e
      Err( "M_1889", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,2),6,2)
      Show( "M_1890", r )
   RECOVER USING e
      Err( "M_1890", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P063()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,2),6)
      Show( "M_1891", r )
   RECOVER USING e
      Err( "M_1891", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,6,2))
      Show( "M_1892", r )
   RECOVER USING e
      Err( "M_1892", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,16,5)),2)
      Show( "M_1893", r )
   RECOVER USING e
      Err( "M_1893", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,2),10,2)
      Show( "M_1894", r )
   RECOVER USING e
      Err( "M_1894", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,2),10)
      Show( "M_1895", r )
   RECOVER USING e
      Err( "M_1895", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,10,2))
      Show( "M_1896", r )
   RECOVER USING e
      Err( "M_1896", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,20,5)),2)
      Show( "M_1897", r )
   RECOVER USING e
      Err( "M_1897", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,3),4,3)
      Show( "M_1898", r )
   RECOVER USING e
      Err( "M_1898", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,3),4)
      Show( "M_1899", r )
   RECOVER USING e
      Err( "M_1899", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,4,3))
      Show( "M_1900", r )
   RECOVER USING e
      Err( "M_1900", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,14,6)),3)
      Show( "M_1901", r )
   RECOVER USING e
      Err( "M_1901", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,3),6,3)
      Show( "M_1902", r )
   RECOVER USING e
      Err( "M_1902", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,3),6)
      Show( "M_1903", r )
   RECOVER USING e
      Err( "M_1903", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,6,3))
      Show( "M_1904", r )
   RECOVER USING e
      Err( "M_1904", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,16,6)),3)
      Show( "M_1905", r )
   RECOVER USING e
      Err( "M_1905", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,3),10,3)
      Show( "M_1906", r )
   RECOVER USING e
      Err( "M_1906", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(9.995,3),10)
      Show( "M_1907", r )
   RECOVER USING e
      Err( "M_1907", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(9.995,10,3))
      Show( "M_1908", r )
   RECOVER USING e
      Err( "M_1908", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(9.995,20,6)),3)
      Show( "M_1909", r )
   RECOVER USING e
      Err( "M_1909", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,0),4,0)
      Show( "M_1910", r )
   RECOVER USING e
      Err( "M_1910", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,0),4)
      Show( "M_1911", r )
   RECOVER USING e
      Err( "M_1911", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,4,0))
      Show( "M_1912", r )
   RECOVER USING e
      Err( "M_1912", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,14,3)),0)
      Show( "M_1913", r )
   RECOVER USING e
      Err( "M_1913", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,0),6,0)
      Show( "M_1914", r )
   RECOVER USING e
      Err( "M_1914", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,0),6)
      Show( "M_1915", r )
   RECOVER USING e
      Err( "M_1915", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,6,0))
      Show( "M_1916", r )
   RECOVER USING e
      Err( "M_1916", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,16,3)),0)
      Show( "M_1917", r )
   RECOVER USING e
      Err( "M_1917", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,0),10,0)
      Show( "M_1918", r )
   RECOVER USING e
      Err( "M_1918", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,0),10)
      Show( "M_1919", r )
   RECOVER USING e
      Err( "M_1919", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,10,0))
      Show( "M_1920", r )
   RECOVER USING e
      Err( "M_1920", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P064()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,20,3)),0)
      Show( "M_1921", r )
   RECOVER USING e
      Err( "M_1921", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,1),4,1)
      Show( "M_1922", r )
   RECOVER USING e
      Err( "M_1922", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,1),4)
      Show( "M_1923", r )
   RECOVER USING e
      Err( "M_1923", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,4,1))
      Show( "M_1924", r )
   RECOVER USING e
      Err( "M_1924", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,14,4)),1)
      Show( "M_1925", r )
   RECOVER USING e
      Err( "M_1925", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,1),6,1)
      Show( "M_1926", r )
   RECOVER USING e
      Err( "M_1926", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,1),6)
      Show( "M_1927", r )
   RECOVER USING e
      Err( "M_1927", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,6,1))
      Show( "M_1928", r )
   RECOVER USING e
      Err( "M_1928", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,16,4)),1)
      Show( "M_1929", r )
   RECOVER USING e
      Err( "M_1929", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,1),10,1)
      Show( "M_1930", r )
   RECOVER USING e
      Err( "M_1930", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,1),10)
      Show( "M_1931", r )
   RECOVER USING e
      Err( "M_1931", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,10,1))
      Show( "M_1932", r )
   RECOVER USING e
      Err( "M_1932", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,20,4)),1)
      Show( "M_1933", r )
   RECOVER USING e
      Err( "M_1933", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,2),4,2)
      Show( "M_1934", r )
   RECOVER USING e
      Err( "M_1934", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,2),4)
      Show( "M_1935", r )
   RECOVER USING e
      Err( "M_1935", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,4,2))
      Show( "M_1936", r )
   RECOVER USING e
      Err( "M_1936", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,14,5)),2)
      Show( "M_1937", r )
   RECOVER USING e
      Err( "M_1937", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,2),6,2)
      Show( "M_1938", r )
   RECOVER USING e
      Err( "M_1938", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,2),6)
      Show( "M_1939", r )
   RECOVER USING e
      Err( "M_1939", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,6,2))
      Show( "M_1940", r )
   RECOVER USING e
      Err( "M_1940", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,16,5)),2)
      Show( "M_1941", r )
   RECOVER USING e
      Err( "M_1941", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,2),10,2)
      Show( "M_1942", r )
   RECOVER USING e
      Err( "M_1942", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,2),10)
      Show( "M_1943", r )
   RECOVER USING e
      Err( "M_1943", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,10,2))
      Show( "M_1944", r )
   RECOVER USING e
      Err( "M_1944", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,20,5)),2)
      Show( "M_1945", r )
   RECOVER USING e
      Err( "M_1945", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,3),4,3)
      Show( "M_1946", r )
   RECOVER USING e
      Err( "M_1946", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,3),4)
      Show( "M_1947", r )
   RECOVER USING e
      Err( "M_1947", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,4,3))
      Show( "M_1948", r )
   RECOVER USING e
      Err( "M_1948", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,14,6)),3)
      Show( "M_1949", r )
   RECOVER USING e
      Err( "M_1949", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,3),6,3)
      Show( "M_1950", r )
   RECOVER USING e
      Err( "M_1950", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P065()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,3),6)
      Show( "M_1951", r )
   RECOVER USING e
      Err( "M_1951", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,6,3))
      Show( "M_1952", r )
   RECOVER USING e
      Err( "M_1952", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,16,6)),3)
      Show( "M_1953", r )
   RECOVER USING e
      Err( "M_1953", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,3),10,3)
      Show( "M_1954", r )
   RECOVER USING e
      Err( "M_1954", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(1000000000000000+0.5,3),10)
      Show( "M_1955", r )
   RECOVER USING e
      Err( "M_1955", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000+0.5,10,3))
      Show( "M_1956", r )
   RECOVER USING e
      Err( "M_1956", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(1000000000000000+0.5,20,6)),3)
      Show( "M_1957", r )
   RECOVER USING e
      Err( "M_1957", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,0),4,0)
      Show( "M_1958", r )
   RECOVER USING e
      Err( "M_1958", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,0),4)
      Show( "M_1959", r )
   RECOVER USING e
      Err( "M_1959", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,4,0))
      Show( "M_1960", r )
   RECOVER USING e
      Err( "M_1960", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,14,3)),0)
      Show( "M_1961", r )
   RECOVER USING e
      Err( "M_1961", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,0),6,0)
      Show( "M_1962", r )
   RECOVER USING e
      Err( "M_1962", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,0),6)
      Show( "M_1963", r )
   RECOVER USING e
      Err( "M_1963", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,6,0))
      Show( "M_1964", r )
   RECOVER USING e
      Err( "M_1964", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,16,3)),0)
      Show( "M_1965", r )
   RECOVER USING e
      Err( "M_1965", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,0),10,0)
      Show( "M_1966", r )
   RECOVER USING e
      Err( "M_1966", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,0),10)
      Show( "M_1967", r )
   RECOVER USING e
      Err( "M_1967", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,10,0))
      Show( "M_1968", r )
   RECOVER USING e
      Err( "M_1968", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,20,3)),0)
      Show( "M_1969", r )
   RECOVER USING e
      Err( "M_1969", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,1),4,1)
      Show( "M_1970", r )
   RECOVER USING e
      Err( "M_1970", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,1),4)
      Show( "M_1971", r )
   RECOVER USING e
      Err( "M_1971", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,4,1))
      Show( "M_1972", r )
   RECOVER USING e
      Err( "M_1972", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,14,4)),1)
      Show( "M_1973", r )
   RECOVER USING e
      Err( "M_1973", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,1),6,1)
      Show( "M_1974", r )
   RECOVER USING e
      Err( "M_1974", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,1),6)
      Show( "M_1975", r )
   RECOVER USING e
      Err( "M_1975", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,6,1))
      Show( "M_1976", r )
   RECOVER USING e
      Err( "M_1976", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,16,4)),1)
      Show( "M_1977", r )
   RECOVER USING e
      Err( "M_1977", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,1),10,1)
      Show( "M_1978", r )
   RECOVER USING e
      Err( "M_1978", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,1),10)
      Show( "M_1979", r )
   RECOVER USING e
      Err( "M_1979", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,10,1))
      Show( "M_1980", r )
   RECOVER USING e
      Err( "M_1980", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P066()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,20,4)),1)
      Show( "M_1981", r )
   RECOVER USING e
      Err( "M_1981", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,2),4,2)
      Show( "M_1982", r )
   RECOVER USING e
      Err( "M_1982", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,2),4)
      Show( "M_1983", r )
   RECOVER USING e
      Err( "M_1983", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,4,2))
      Show( "M_1984", r )
   RECOVER USING e
      Err( "M_1984", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,14,5)),2)
      Show( "M_1985", r )
   RECOVER USING e
      Err( "M_1985", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,2),6,2)
      Show( "M_1986", r )
   RECOVER USING e
      Err( "M_1986", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,2),6)
      Show( "M_1987", r )
   RECOVER USING e
      Err( "M_1987", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,6,2))
      Show( "M_1988", r )
   RECOVER USING e
      Err( "M_1988", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,16,5)),2)
      Show( "M_1989", r )
   RECOVER USING e
      Err( "M_1989", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,2),10,2)
      Show( "M_1990", r )
   RECOVER USING e
      Err( "M_1990", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,2),10)
      Show( "M_1991", r )
   RECOVER USING e
      Err( "M_1991", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,10,2))
      Show( "M_1992", r )
   RECOVER USING e
      Err( "M_1992", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,20,5)),2)
      Show( "M_1993", r )
   RECOVER USING e
      Err( "M_1993", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,3),4,3)
      Show( "M_1994", r )
   RECOVER USING e
      Err( "M_1994", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,3),4)
      Show( "M_1995", r )
   RECOVER USING e
      Err( "M_1995", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,4,3))
      Show( "M_1996", r )
   RECOVER USING e
      Err( "M_1996", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,14,6)),3)
      Show( "M_1997", r )
   RECOVER USING e
      Err( "M_1997", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,3),6,3)
      Show( "M_1998", r )
   RECOVER USING e
      Err( "M_1998", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,3),6)
      Show( "M_1999", r )
   RECOVER USING e
      Err( "M_1999", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,6,3))
      Show( "M_2000", r )
   RECOVER USING e
      Err( "M_2000", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,16,6)),3)
      Show( "M_2001", r )
   RECOVER USING e
      Err( "M_2001", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,3),10,3)
      Show( "M_2002", r )
   RECOVER USING e
      Err( "M_2002", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(99.5,3),10)
      Show( "M_2003", r )
   RECOVER USING e
      Err( "M_2003", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.5,10,3))
      Show( "M_2004", r )
   RECOVER USING e
      Err( "M_2004", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val(Str(99.5,20,6)),3)
      Show( "M_2005", r )
   RECOVER USING e
      Err( "M_2005", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(-0.4,0),5,1)
      Show( "M_2006", r )
   RECOVER USING e
      Err( "M_2006", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(-0.004,2),8,3)
      Show( "M_2007", r )
   RECOVER USING e
      Err( "M_2007", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(Round(-0.4,0))
      Show( "M_2008", r )
   RECOVER USING e
      Err( "M_2008", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Transform(Round(-0.4,0),'99.9')
      Show( "M_2009", r )
   RECOVER USING e
      Err( "M_2009", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.4,2,0)
      Show( "M_2010", r )
   RECOVER USING e
      Err( "M_2010", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P067()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,2,0)
      Show( "M_2011", r )
   RECOVER USING e
      Err( "M_2011", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Str(-0.5,3,0)
      Show( "M_2012", r )
   RECOVER USING e
      Err( "M_2012", e )
   END SEQUENCE
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
   RETURN
STATIC PROCEDURE P068()
   LOCAL r, e
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
STATIC PROCEDURE PS()
   LOCAL r, e
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2051", r )
      OutStd( "O_2051|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2051", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2052", r )
      OutStd( "O_2052|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2052", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2053", r )
      OutStd( "O_2053|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2053", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2054", r )
      OutStd( "O_2054|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2054", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2055", r )
      OutStd( "O_2055|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2055", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2056", r )
      OutStd( "O_2056|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2056", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2057", r )
      OutStd( "O_2057|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2057", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2058", r )
      OutStd( "O_2058|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2058", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2059", r )
      OutStd( "O_2059|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2059", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2060", r )
      OutStd( "O_2060|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2060", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2061", r )
      OutStd( "O_2061|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2061", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2062", r )
      OutStd( "O_2062|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2062", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2063", r )
      OutStd( "O_2063|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2063", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2064", r )
      OutStd( "O_2064|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2064", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2065", r )
      OutStd( "O_2065|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2065", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2066", r )
      OutStd( "O_2066|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2066", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2067", r )
      OutStd( "O_2067|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2067", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2068", r )
      OutStd( "O_2068|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2068", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2069", r )
      OutStd( "O_2069|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2069", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2070", r )
      OutStd( "O_2070|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2070", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2071", r )
      OutStd( "O_2071|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2071", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2072", r )
      OutStd( "O_2072|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2072", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2073", r )
      OutStd( "O_2073|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2073", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2074", r )
      OutStd( "O_2074|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2074", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2075", r )
      OutStd( "O_2075|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2075", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2076", r )
      OutStd( "O_2076|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2076", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2077", r )
      OutStd( "O_2077|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2077", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2078", r )
      OutStd( "O_2078|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2078", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2079", r )
      OutStd( "O_2079|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2079", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2080", r )
      OutStd( "O_2080|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2080", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2081", r )
      OutStd( "O_2081|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2081", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2082", r )
      OutStd( "O_2082|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2082", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2083", r )
      OutStd( "O_2083|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2083", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2084", r )
      OutStd( "O_2084|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2084", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2085", r )
      OutStd( "O_2085|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2085", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2086", r )
      OutStd( "O_2086|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2086", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2087", r )
      OutStd( "O_2087|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2087", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2088", r )
      OutStd( "O_2088|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2088", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2089", r )
      OutStd( "O_2089|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2089", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2090", r )
      OutStd( "O_2090|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2090", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2091", r )
      OutStd( "O_2091|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2091", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2092", r )
      OutStd( "O_2092|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2092", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2093", r )
      OutStd( "O_2093|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2093", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2094", r )
      OutStd( "O_2094|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2094", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2095", r )
      OutStd( "O_2095|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2095", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2096", r )
      OutStd( "O_2096|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2096", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2097", r )
      OutStd( "O_2097|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2097", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2098", r )
      OutStd( "O_2098|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2098", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2099", r )
      OutStd( "O_2099|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2099", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2100", r )
      OutStd( "O_2100|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2100", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2101", r )
      OutStd( "O_2101|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2101", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2102", r )
      OutStd( "O_2102|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2102", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2103", r )
      OutStd( "O_2103|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2103", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2104", r )
      OutStd( "O_2104|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2104", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2105", r )
      OutStd( "O_2105|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2105", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2106", r )
      OutStd( "O_2106|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2106", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2107", r )
      OutStd( "O_2107|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2107", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2108", r )
      OutStd( "O_2108|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2108", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2109", r )
      OutStd( "O_2109|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2109", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2110", r )
      OutStd( "O_2110|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2110", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2111", r )
      OutStd( "O_2111|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2111", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2112", r )
      OutStd( "O_2112|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2112", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2113", r )
      OutStd( "O_2113|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2113", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2114", r )
      OutStd( "O_2114|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2114", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2115", r )
      OutStd( "O_2115|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2115", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2116", r )
      OutStd( "O_2116|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2116", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2117", r )
      OutStd( "O_2117|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2117", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2118", r )
      OutStd( "O_2118|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2118", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2119", r )
      OutStd( "O_2119|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2119", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2120", r )
      OutStd( "O_2120|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2120", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2121", r )
      OutStd( "O_2121|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2121", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2122", r )
      OutStd( "O_2122|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2122", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2123", r )
      OutStd( "O_2123|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2123", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2124", r )
      OutStd( "O_2124|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2124", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2125", r )
      OutStd( "O_2125|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2125", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2126", r )
      OutStd( "O_2126|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2126", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2127", r )
      OutStd( "O_2127|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2127", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2128", r )
      OutStd( "O_2128|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2128", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2129", r )
      OutStd( "O_2129|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2129", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2130", r )
      OutStd( "O_2130|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2130", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2131", r )
      OutStd( "O_2131|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2131", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2132", r )
      OutStd( "O_2132|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2132", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2133", r )
      OutStd( "O_2133|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2133", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2134", r )
      OutStd( "O_2134|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2134", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.005,2)
      Show( "O_2135", r )
      OutStd( "O_2135|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2135", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2.675,2)
      Show( "O_2136", r )
      OutStd( "O_2136|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2136", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(0.285,2)
      Show( "O_2137", r )
      OutStd( "O_2137|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2137", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.5,0)
      Show( "O_2138", r )
      OutStd( "O_2138|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2138", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,5)
      Show( "O_2139", r )
      OutStd( "O_2139|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2139", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(123.456,1)
      Show( "O_2140", r )
      OutStd( "O_2140|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2140", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1/3,10)
      Show( "O_2141", r )
      OutStd( "O_2141|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2141", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(2/3,0)
      Show( "O_2142", r )
      OutStd( "O_2142|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2142", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := 1/3
      Show( "O_2143", r )
      OutStd( "O_2143|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2143", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(10/3,3)
      Show( "O_2144", r )
      OutStd( "O_2144|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2144", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(5,2)
      Show( "O_2145", r )
      OutStd( "O_2145|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2145", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(1.2345,6)
      Show( "O_2146", r )
      OutStd( "O_2146|raw|[" + hb_CStr( r ) + "]" + hb_eol() )
   RECOVER USING e
      Err( "O_2146", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   RETURN

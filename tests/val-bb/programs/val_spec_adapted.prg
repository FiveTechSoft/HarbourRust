// Val() clean-room black-box spec (adapted harness).
// Oracle: val-oracle-spec (spec tgz sha256
// 95247f25c93c01899034cfe86a949140565fc9d705e6c255831e983002d1b6e7;
// 971 cases). This program is the oracle's val_spec.prg with two
// LABELLED adaptations (search "ADAPTED"); the original spec files are
// untouched in the tgz. Expected output: the oracle's out.txt; the diff
// against it is byte-pinned by check.sh (pinned-diffs/full-spec.diff)
// and the deviating rows are listed in known-mismatches.txt.
//
// Adaptation 1: Err() - no error-object system; the caught value IS its
//   description string and is COMPARED against "Argument error" (the
//   only description the oracle reports for Val); operation/subCode/
//   genCode are literal stand-ins, not verified.
// Adaptation 2: four macro rows written as direct calls
//   (statement-context macro evaluation is outside this compiler
//   increment; same shape as the round package): D_0322
//   (&("Val(Date())") -> Val(Date())), D_0323/D_0324 (extra arguments
//   kept) and D_0325 (&("Val(NIL,NIL)") -> Val(NIL,NIL) - the row
//   stays, as ERR row 325; the expected bytes are the oracle's
//   verbatim out.txt for all 971 rows).
STATIC PROCEDURE Show( id, r )
   LOCAL t := ValType( r )
   IF t == "N"
      OutStd( id + "|N|[" + hb_ntos( r ) + "]|[" + Str( r ) + "]|[" + Str( r, 30, 12 ) + "]|[" + Str( r, 34, 17 ) + "]|[" + hb_CStr( r ) + "]" + hb_eol() )
   ELSEIF t == "L"
      OutStd( id + "|L|" + iif( r, ".T.", ".F." ) + hb_eol() )
   ELSE
      OutStd( id + "|" + t + "|" + hb_CStr( r ) + hb_eol() )
   ENDIF
   RETURN
STATIC PROCEDURE Err( id, e )
   // ADAPTED (val harness adaptation 1): the captured value is checked,
   // not assumed - it must equal "Argument error", the one description
   // the oracle reports for every Val error row. Fields 2-4 are literal
   // stand-ins: this runtime's caught value carries no
   // operation/subCode/genCode.
   LOCAL d := hb_CStr( e )
   IF d == "Argument error"
      OutStd( id + "|ERR|Argument error|VAL|      1098|         1" + hb_eol() )
   ELSE
      OutStd( id + "|ERR-DESC-MISMATCH|[" + d + "]" + hb_eol() )
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
   PS()
   RETURN
STATIC PROCEDURE P000()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0")
      Show( "A_0001", r )
   RECOVER USING e
      Err( "A_0001", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1")
      Show( "A_0002", r )
   RECOVER USING e
      Err( "A_0002", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-1")
      Show( "A_0003", r )
   RECOVER USING e
      Err( "A_0003", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("+1")
      Show( "A_0004", r )
   RECOVER USING e
      Err( "A_0004", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("7")
      Show( "A_0005", r )
   RECOVER USING e
      Err( "A_0005", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("42")
      Show( "A_0006", r )
   RECOVER USING e
      Err( "A_0006", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-42")
      Show( "A_0007", r )
   RECOVER USING e
      Err( "A_0007", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("007")
      Show( "A_0008", r )
   RECOVER USING e
      Err( "A_0008", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("00012")
      Show( "A_0009", r )
   RECOVER USING e
      Err( "A_0009", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-0")
      Show( "A_0010", r )
   RECOVER USING e
      Err( "A_0010", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("+0")
      Show( "A_0011", r )
   RECOVER USING e
      Err( "A_0011", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.0")
      Show( "A_0012", r )
   RECOVER USING e
      Err( "A_0012", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-0.0")
      Show( "A_0013", r )
   RECOVER USING e
      Err( "A_0013", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.5")
      Show( "A_0014", r )
   RECOVER USING e
      Err( "A_0014", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-0.5")
      Show( "A_0015", r )
   RECOVER USING e
      Err( "A_0015", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(".5")
      Show( "A_0016", r )
   RECOVER USING e
      Err( "A_0016", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-.5")
      Show( "A_0017", r )
   RECOVER USING e
      Err( "A_0017", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("+.5")
      Show( "A_0018", r )
   RECOVER USING e
      Err( "A_0018", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("5.")
      Show( "A_0019", r )
   RECOVER USING e
      Err( "A_0019", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-5.")
      Show( "A_0020", r )
   RECOVER USING e
      Err( "A_0020", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("+5.")
      Show( "A_0021", r )
   RECOVER USING e
      Err( "A_0021", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.")
      Show( "A_0022", r )
   RECOVER USING e
      Err( "A_0022", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.5")
      Show( "A_0023", r )
   RECOVER USING e
      Err( "A_0023", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.05")
      Show( "A_0024", r )
   RECOVER USING e
      Err( "A_0024", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")
      Show( "A_0025", r )
   RECOVER USING e
      Err( "A_0025", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")
      Show( "A_0026", r )
   RECOVER USING e
      Err( "A_0026", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")
      Show( "A_0027", r )
   RECOVER USING e
      Err( "A_0027", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")
      Show( "A_0028", r )
   RECOVER USING e
      Err( "A_0028", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")
      Show( "A_0029", r )
   RECOVER USING e
      Err( "A_0029", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.3")
      Show( "A_0030", r )
   RECOVER USING e
      Err( "A_0030", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P001()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.30")
      Show( "A_0031", r )
   RECOVER USING e
      Err( "A_0031", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.300")
      Show( "A_0032", r )
   RECOVER USING e
      Err( "A_0032", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.14159")
      Show( "A_0033", r )
   RECOVER USING e
      Err( "A_0033", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.141592653589793")
      Show( "A_0034", r )
   RECOVER USING e
      Err( "A_0034", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.14159265358979323846")
      Show( "A_0035", r )
   RECOVER USING e
      Err( "A_0035", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.718281828459045")
      Show( "A_0036", r )
   RECOVER USING e
      Err( "A_0036", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1234567890123456789")
      Show( "A_0037", r )
   RECOVER USING e
      Err( "A_0037", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.0000000001")
      Show( "A_0038", r )
   RECOVER USING e
      Err( "A_0038", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.00000000000000000001")
      Show( "A_0039", r )
   RECOVER USING e
      Err( "A_0039", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789")
      Show( "A_0040", r )
   RECOVER USING e
      Err( "A_0040", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1234567890")
      Show( "A_0041", r )
   RECOVER USING e
      Err( "A_0041", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12345678901")
      Show( "A_0042", r )
   RECOVER USING e
      Err( "A_0042", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2147483647")
      Show( "A_0043", r )
   RECOVER USING e
      Err( "A_0043", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2147483648")
      Show( "A_0044", r )
   RECOVER USING e
      Err( "A_0044", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-2147483648")
      Show( "A_0045", r )
   RECOVER USING e
      Err( "A_0045", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-2147483649")
      Show( "A_0046", r )
   RECOVER USING e
      Err( "A_0046", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4294967295")
      Show( "A_0047", r )
   RECOVER USING e
      Err( "A_0047", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4294967296")
      Show( "A_0048", r )
   RECOVER USING e
      Err( "A_0048", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("9007199254740991")
      Show( "A_0049", r )
   RECOVER USING e
      Err( "A_0049", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("9007199254740992")
      Show( "A_0050", r )
   RECOVER USING e
      Err( "A_0050", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("9007199254740993")
      Show( "A_0051", r )
   RECOVER USING e
      Err( "A_0051", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("9223372036854775807")
      Show( "A_0052", r )
   RECOVER USING e
      Err( "A_0052", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("9223372036854775808")
      Show( "A_0053", r )
   RECOVER USING e
      Err( "A_0053", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-9223372036854775808")
      Show( "A_0054", r )
   RECOVER USING e
      Err( "A_0054", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("18446744073709551615")
      Show( "A_0055", r )
   RECOVER USING e
      Err( "A_0055", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("18446744073709551616")
      Show( "A_0056", r )
   RECOVER USING e
      Err( "A_0056", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999")
      Show( "A_0057", r )
   RECOVER USING e
      Err( "A_0057", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")
      Show( "A_0058", r )
   RECOVER USING e
      Err( "A_0058", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1000000000000000")
      Show( "A_0059", r )
   RECOVER USING e
      Err( "A_0059", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1000000000000000.5")
      Show( "A_0060", r )
   RECOVER USING e
      Err( "A_0060", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P002()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")
      Show( "A_0061", r )
   RECOVER USING e
      Err( "A_0061", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12345678901234567890")
      Show( "A_0062", r )
   RECOVER USING e
      Err( "A_0062", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345678901234567890")
      Show( "A_0063", r )
   RECOVER USING e
      Err( "A_0063", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("99999999999999999999999999999999999999")
      Show( "A_0064", r )
   RECOVER USING e
      Err( "A_0064", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1000000000000000000000000000000")
      Show( "A_0065", r )
   RECOVER USING e
      Err( "A_0065", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
      Show( "A_0066", r )
   RECOVER USING e
      Err( "A_0066", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
      Show( "A_0067", r )
   RECOVER USING e
      Err( "A_0067", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.0000000000000000000000000000001")
      Show( "A_0068", r )
   RECOVER USING e
      Err( "A_0068", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.000000000000000000000000000000")
      Show( "A_0069", r )
   RECOVER USING e
      Err( "A_0069", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.0000000000000000000000000000001")
      Show( "A_0070", r )
   RECOVER USING e
      Err( "A_0070", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e5")
      Show( "A_0071", r )
   RECOVER USING e
      Err( "A_0071", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1E5")
      Show( "A_0072", r )
   RECOVER USING e
      Err( "A_0072", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e+5")
      Show( "A_0073", r )
   RECOVER USING e
      Err( "A_0073", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e-5")
      Show( "A_0074", r )
   RECOVER USING e
      Err( "A_0074", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.5e3")
      Show( "A_0075", r )
   RECOVER USING e
      Err( "A_0075", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.5E-3")
      Show( "A_0076", r )
   RECOVER USING e
      Err( "A_0076", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e")
      Show( "A_0077", r )
   RECOVER USING e
      Err( "A_0077", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e+")
      Show( "A_0078", r )
   RECOVER USING e
      Err( "A_0078", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("e5")
      Show( "A_0079", r )
   RECOVER USING e
      Err( "A_0079", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e5.5")
      Show( "A_0080", r )
   RECOVER USING e
      Err( "A_0080", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e400")
      Show( "A_0081", r )
   RECOVER USING e
      Err( "A_0081", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1d5")
      Show( "A_0082", r )
   RECOVER USING e
      Err( "A_0082", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1 e5")
      Show( "A_0083", r )
   RECOVER USING e
      Err( "A_0083", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12e")
      Show( "A_0084", r )
   RECOVER USING e
      Err( "A_0084", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0e0")
      Show( "A_0085", r )
   RECOVER USING e
      Err( "A_0085", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.2.3")
      Show( "A_0086", r )
   RECOVER USING e
      Err( "A_0086", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1..2")
      Show( "A_0087", r )
   RECOVER USING e
      Err( "A_0087", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("..5")
      Show( "A_0088", r )
   RECOVER USING e
      Err( "A_0088", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-.")
      Show( "A_0089", r )
   RECOVER USING e
      Err( "A_0089", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-")
      Show( "A_0090", r )
   RECOVER USING e
      Err( "A_0090", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P003()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("+")
      Show( "A_0091", r )
   RECOVER USING e
      Err( "A_0091", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(".")
      Show( "A_0092", r )
   RECOVER USING e
      Err( "A_0092", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" ")
      Show( "A_0093", r )
   RECOVER USING e
      Err( "A_0093", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  ")
      Show( "A_0094", r )
   RECOVER USING e
      Err( "A_0094", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("")
      Show( "A_0095", r )
   RECOVER USING e
      Err( "A_0095", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("   12")
      Show( "A_0096", r )
   RECOVER USING e
      Err( "A_0096", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12   ")
      Show( "A_0097", r )
   RECOVER USING e
      Err( "A_0097", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  12  ")
      Show( "A_0098", r )
   RECOVER USING e
      Err( "A_0098", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "12")
      Show( "A_0099", r )
   RECOVER USING e
      Err( "A_0099", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "12")
      Show( "A_0100", r )
   RECOVER USING e
      Err( "A_0100", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(13) + Chr(10) + "12")
      Show( "A_0101", r )
   RECOVER USING e
      Err( "A_0101", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" " + Chr(9) + " 12.5")
      Show( "A_0102", r )
   RECOVER USING e
      Err( "A_0102", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" - 5")
      Show( "A_0103", r )
   RECOVER USING e
      Err( "A_0103", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("- 5")
      Show( "A_0104", r )
   RECOVER USING e
      Err( "A_0104", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("--5")
      Show( "A_0105", r )
   RECOVER USING e
      Err( "A_0105", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("+-5")
      Show( "A_0106", r )
   RECOVER USING e
      Err( "A_0106", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-+5")
      Show( "A_0107", r )
   RECOVER USING e
      Err( "A_0107", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("++5")
      Show( "A_0108", r )
   RECOVER USING e
      Err( "A_0108", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1 2")
      Show( "A_0109", r )
   RECOVER USING e
      Err( "A_0109", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1,5")
      Show( "A_0110", r )
   RECOVER USING e
      Err( "A_0110", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1_000")
      Show( "A_0111", r )
   RECOVER USING e
      Err( "A_0111", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1'000")
      Show( "A_0112", r )
   RECOVER USING e
      Err( "A_0112", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12abc")
      Show( "A_0113", r )
   RECOVER USING e
      Err( "A_0113", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("abc")
      Show( "A_0114", r )
   RECOVER USING e
      Err( "A_0114", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("abc12")
      Show( "A_0115", r )
   RECOVER USING e
      Err( "A_0115", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("a1")
      Show( "A_0116", r )
   RECOVER USING e
      Err( "A_0116", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1a")
      Show( "A_0117", r )
   RECOVER USING e
      Err( "A_0117", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.5abc")
      Show( "A_0118", r )
   RECOVER USING e
      Err( "A_0118", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.5.5")
      Show( "A_0119", r )
   RECOVER USING e
      Err( "A_0119", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("- 12.5x")
      Show( "A_0120", r )
   RECOVER USING e
      Err( "A_0120", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P004()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0x1F")
      Show( "A_0121", r )
   RECOVER USING e
      Err( "A_0121", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0X1f")
      Show( "A_0122", r )
   RECOVER USING e
      Err( "A_0122", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0x")
      Show( "A_0123", r )
   RECOVER USING e
      Err( "A_0123", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0b101")
      Show( "A_0124", r )
   RECOVER USING e
      Err( "A_0124", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0o17")
      Show( "A_0125", r )
   RECOVER USING e
      Err( "A_0125", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1f")
      Show( "A_0126", r )
   RECOVER USING e
      Err( "A_0126", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1L")
      Show( "A_0127", r )
   RECOVER USING e
      Err( "A_0127", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("$5")
      Show( "A_0128", r )
   RECOVER USING e
      Err( "A_0128", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("5$")
      Show( "A_0129", r )
   RECOVER USING e
      Err( "A_0129", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("(5)")
      Show( "A_0130", r )
   RECOVER USING e
      Err( "A_0130", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("5-")
      Show( "A_0131", r )
   RECOVER USING e
      Err( "A_0131", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("5+")
      Show( "A_0132", r )
   RECOVER USING e
      Err( "A_0132", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("#5")
      Show( "A_0133", r )
   RECOVER USING e
      Err( "A_0133", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1/2")
      Show( "A_0134", r )
   RECOVER USING e
      Err( "A_0134", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1*2")
      Show( "A_0135", r )
   RECOVER USING e
      Err( "A_0135", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("NaN")
      Show( "A_0136", r )
   RECOVER USING e
      Err( "A_0136", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("nan")
      Show( "A_0137", r )
   RECOVER USING e
      Err( "A_0137", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("inf")
      Show( "A_0138", r )
   RECOVER USING e
      Err( "A_0138", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("Infinity")
      Show( "A_0139", r )
   RECOVER USING e
      Err( "A_0139", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-inf")
      Show( "A_0140", r )
   RECOVER USING e
      Err( "A_0140", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e1000")
      Show( "A_0141", r )
   RECOVER USING e
      Err( "A_0141", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(217) + Chr(163))
      Show( "A_0142", r )
   RECOVER USING e
      Err( "A_0142", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12" + Chr(217) + Chr(163))
      Show( "A_0143", r )
   RECOVER USING e
      Err( "A_0143", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(239) + Chr(188) + Chr(145) + Chr(239) + Chr(188) + Chr(146))
      Show( "A_0144", r )
   RECOVER USING e
      Err( "A_0144", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(0))
      Show( "A_0145", r )
   RECOVER USING e
      Err( "A_0145", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12" + Chr(0) + "34")
      Show( "A_0146", r )
   RECOVER USING e
      Err( "A_0146", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1" + Chr(0) + "2")
      Show( "A_0147", r )
   RECOVER USING e
      Err( "A_0147", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(194) + Chr(160) + "12")
      Show( "A_0148", r )
   RECOVER USING e
      Err( "A_0148", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12" + Chr(194) + Chr(160))
      Show( "A_0149", r )
   RECOVER USING e
      Err( "A_0149", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12.50")
      Show( "A_0150", r )
   RECOVER USING e
      Err( "A_0150", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P005()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12.500000")
      Show( "A_0151", r )
   RECOVER USING e
      Err( "A_0151", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-12.5000")
      Show( "A_0152", r )
   RECOVER USING e
      Err( "A_0152", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("00.5")
      Show( "A_0153", r )
   RECOVER USING e
      Err( "A_0153", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.50")
      Show( "A_0154", r )
   RECOVER USING e
      Err( "A_0154", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("000.000")
      Show( "A_0155", r )
   RECOVER USING e
      Err( "A_0155", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-000.000")
      Show( "A_0156", r )
   RECOVER USING e
      Err( "A_0156", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1 000")
      Show( "A_0157", r )
   RECOVER USING e
      Err( "A_0157", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("+ 5")
      Show( "A_0158", r )
   RECOVER USING e
      Err( "A_0158", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.5 e3")
      Show( "A_0159", r )
   RECOVER USING e
      Err( "A_0159", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.5e 3")
      Show( "A_0160", r )
   RECOVER USING e
      Err( "A_0160", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.e3")
      Show( "A_0161", r )
   RECOVER USING e
      Err( "A_0161", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(".e3")
      Show( "A_0162", r )
   RECOVER USING e
      Err( "A_0162", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("5e-324")
      Show( "A_0163", r )
   RECOVER USING e
      Err( "A_0163", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.7976931348623157e308")
      Show( "A_0164", r )
   RECOVER USING e
      Err( "A_0164", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1e1")
      Show( "A_0165", r )
   RECOVER USING e
      Err( "A_0165", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.01e2")
      Show( "A_0166", r )
   RECOVER USING e
      Err( "A_0166", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.001e3")
      Show( "A_0167", r )
   RECOVER USING e
      Err( "A_0167", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e0")
      Show( "A_0168", r )
   RECOVER USING e
      Err( "A_0168", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e1")
      Show( "A_0169", r )
   RECOVER USING e
      Err( "A_0169", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e2")
      Show( "A_0170", r )
   RECOVER USING e
      Err( "A_0170", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e15")
      Show( "A_0171", r )
   RECOVER USING e
      Err( "A_0171", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e16")
      Show( "A_0172", r )
   RECOVER USING e
      Err( "A_0172", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.5e15")
      Show( "A_0173", r )
   RECOVER USING e
      Err( "A_0173", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123.456e-2")
      Show( "A_0174", r )
   RECOVER USING e
      Err( "A_0174", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12345e-10")
      Show( "A_0175", r )
   RECOVER USING e
      Err( "A_0175", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("9.99999e5")
      Show( "A_0176", r )
   RECOVER USING e
      Err( "A_0176", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.5e0")
      Show( "A_0177", r )
   RECOVER USING e
      Err( "A_0177", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("5e-1")
      Show( "A_0178", r )
   RECOVER USING e
      Err( "A_0178", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-5e-1")
      Show( "A_0179", r )
   RECOVER USING e
      Err( "A_0179", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e-0")
      Show( "A_0180", r )
   RECOVER USING e
      Err( "A_0180", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P006()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e+0")
      Show( "A_0181", r )
   RECOVER USING e
      Err( "A_0181", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0x10")
      Show( "A_0182", r )
   RECOVER USING e
      Err( "A_0182", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12.5 ")
      Show( "B_0183", r )
   RECOVER USING e
      Err( "B_0183", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12.5abc")
      Show( "B_0184", r )
   RECOVER USING e
      Err( "B_0184", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12.5x1")
      Show( "B_0185", r )
   RECOVER USING e
      Err( "B_0185", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("12.5.")
      Show( "B_0186", r )
   RECOVER USING e
      Err( "B_0186", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 12.5")
      Show( "B_0187", r )
   RECOVER USING e
      Err( "B_0187", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 12.5 ")
      Show( "B_0188", r )
   RECOVER USING e
      Err( "B_0188", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 12.5abc")
      Show( "B_0189", r )
   RECOVER USING e
      Err( "B_0189", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 12.5x1")
      Show( "B_0190", r )
   RECOVER USING e
      Err( "B_0190", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 12.5.")
      Show( "B_0191", r )
   RECOVER USING e
      Err( "B_0191", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  12.5")
      Show( "B_0192", r )
   RECOVER USING e
      Err( "B_0192", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  12.5 ")
      Show( "B_0193", r )
   RECOVER USING e
      Err( "B_0193", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  12.5abc")
      Show( "B_0194", r )
   RECOVER USING e
      Err( "B_0194", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  12.5x1")
      Show( "B_0195", r )
   RECOVER USING e
      Err( "B_0195", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  12.5.")
      Show( "B_0196", r )
   RECOVER USING e
      Err( "B_0196", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "12.5")
      Show( "B_0197", r )
   RECOVER USING e
      Err( "B_0197", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "12.5 ")
      Show( "B_0198", r )
   RECOVER USING e
      Err( "B_0198", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "12.5abc")
      Show( "B_0199", r )
   RECOVER USING e
      Err( "B_0199", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "12.5x1")
      Show( "B_0200", r )
   RECOVER USING e
      Err( "B_0200", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "12.5.")
      Show( "B_0201", r )
   RECOVER USING e
      Err( "B_0201", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "12.5")
      Show( "B_0202", r )
   RECOVER USING e
      Err( "B_0202", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "12.5 ")
      Show( "B_0203", r )
   RECOVER USING e
      Err( "B_0203", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "12.5abc")
      Show( "B_0204", r )
   RECOVER USING e
      Err( "B_0204", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "12.5x1")
      Show( "B_0205", r )
   RECOVER USING e
      Err( "B_0205", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "12.5.")
      Show( "B_0206", r )
   RECOVER USING e
      Err( "B_0206", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-3 ")
      Show( "B_0207", r )
   RECOVER USING e
      Err( "B_0207", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-3abc")
      Show( "B_0208", r )
   RECOVER USING e
      Err( "B_0208", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-3x1")
      Show( "B_0209", r )
   RECOVER USING e
      Err( "B_0209", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("-3.")
      Show( "B_0210", r )
   RECOVER USING e
      Err( "B_0210", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P007()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" -3")
      Show( "B_0211", r )
   RECOVER USING e
      Err( "B_0211", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" -3 ")
      Show( "B_0212", r )
   RECOVER USING e
      Err( "B_0212", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" -3abc")
      Show( "B_0213", r )
   RECOVER USING e
      Err( "B_0213", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" -3x1")
      Show( "B_0214", r )
   RECOVER USING e
      Err( "B_0214", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" -3.")
      Show( "B_0215", r )
   RECOVER USING e
      Err( "B_0215", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  -3")
      Show( "B_0216", r )
   RECOVER USING e
      Err( "B_0216", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  -3 ")
      Show( "B_0217", r )
   RECOVER USING e
      Err( "B_0217", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  -3abc")
      Show( "B_0218", r )
   RECOVER USING e
      Err( "B_0218", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  -3x1")
      Show( "B_0219", r )
   RECOVER USING e
      Err( "B_0219", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  -3.")
      Show( "B_0220", r )
   RECOVER USING e
      Err( "B_0220", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "-3")
      Show( "B_0221", r )
   RECOVER USING e
      Err( "B_0221", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "-3 ")
      Show( "B_0222", r )
   RECOVER USING e
      Err( "B_0222", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "-3abc")
      Show( "B_0223", r )
   RECOVER USING e
      Err( "B_0223", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "-3x1")
      Show( "B_0224", r )
   RECOVER USING e
      Err( "B_0224", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "-3.")
      Show( "B_0225", r )
   RECOVER USING e
      Err( "B_0225", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "-3")
      Show( "B_0226", r )
   RECOVER USING e
      Err( "B_0226", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "-3 ")
      Show( "B_0227", r )
   RECOVER USING e
      Err( "B_0227", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "-3abc")
      Show( "B_0228", r )
   RECOVER USING e
      Err( "B_0228", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "-3x1")
      Show( "B_0229", r )
   RECOVER USING e
      Err( "B_0229", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "-3.")
      Show( "B_0230", r )
   RECOVER USING e
      Err( "B_0230", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285 ")
      Show( "B_0231", r )
   RECOVER USING e
      Err( "B_0231", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285abc")
      Show( "B_0232", r )
   RECOVER USING e
      Err( "B_0232", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285x1")
      Show( "B_0233", r )
   RECOVER USING e
      Err( "B_0233", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285.")
      Show( "B_0234", r )
   RECOVER USING e
      Err( "B_0234", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 0.285")
      Show( "B_0235", r )
   RECOVER USING e
      Err( "B_0235", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 0.285 ")
      Show( "B_0236", r )
   RECOVER USING e
      Err( "B_0236", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 0.285abc")
      Show( "B_0237", r )
   RECOVER USING e
      Err( "B_0237", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 0.285x1")
      Show( "B_0238", r )
   RECOVER USING e
      Err( "B_0238", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 0.285.")
      Show( "B_0239", r )
   RECOVER USING e
      Err( "B_0239", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  0.285")
      Show( "B_0240", r )
   RECOVER USING e
      Err( "B_0240", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P008()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  0.285 ")
      Show( "B_0241", r )
   RECOVER USING e
      Err( "B_0241", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  0.285abc")
      Show( "B_0242", r )
   RECOVER USING e
      Err( "B_0242", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  0.285x1")
      Show( "B_0243", r )
   RECOVER USING e
      Err( "B_0243", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  0.285.")
      Show( "B_0244", r )
   RECOVER USING e
      Err( "B_0244", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "0.285")
      Show( "B_0245", r )
   RECOVER USING e
      Err( "B_0245", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "0.285 ")
      Show( "B_0246", r )
   RECOVER USING e
      Err( "B_0246", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "0.285abc")
      Show( "B_0247", r )
   RECOVER USING e
      Err( "B_0247", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "0.285x1")
      Show( "B_0248", r )
   RECOVER USING e
      Err( "B_0248", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "0.285.")
      Show( "B_0249", r )
   RECOVER USING e
      Err( "B_0249", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "0.285")
      Show( "B_0250", r )
   RECOVER USING e
      Err( "B_0250", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "0.285 ")
      Show( "B_0251", r )
   RECOVER USING e
      Err( "B_0251", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "0.285abc")
      Show( "B_0252", r )
   RECOVER USING e
      Err( "B_0252", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "0.285x1")
      Show( "B_0253", r )
   RECOVER USING e
      Err( "B_0253", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "0.285.")
      Show( "B_0254", r )
   RECOVER USING e
      Err( "B_0254", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e3 ")
      Show( "B_0255", r )
   RECOVER USING e
      Err( "B_0255", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e3abc")
      Show( "B_0256", r )
   RECOVER USING e
      Err( "B_0256", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e3x1")
      Show( "B_0257", r )
   RECOVER USING e
      Err( "B_0257", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1e3.")
      Show( "B_0258", r )
   RECOVER USING e
      Err( "B_0258", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 1e3")
      Show( "B_0259", r )
   RECOVER USING e
      Err( "B_0259", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 1e3 ")
      Show( "B_0260", r )
   RECOVER USING e
      Err( "B_0260", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 1e3abc")
      Show( "B_0261", r )
   RECOVER USING e
      Err( "B_0261", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 1e3x1")
      Show( "B_0262", r )
   RECOVER USING e
      Err( "B_0262", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 1e3.")
      Show( "B_0263", r )
   RECOVER USING e
      Err( "B_0263", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  1e3")
      Show( "B_0264", r )
   RECOVER USING e
      Err( "B_0264", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  1e3 ")
      Show( "B_0265", r )
   RECOVER USING e
      Err( "B_0265", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  1e3abc")
      Show( "B_0266", r )
   RECOVER USING e
      Err( "B_0266", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  1e3x1")
      Show( "B_0267", r )
   RECOVER USING e
      Err( "B_0267", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  1e3.")
      Show( "B_0268", r )
   RECOVER USING e
      Err( "B_0268", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "1e3")
      Show( "B_0269", r )
   RECOVER USING e
      Err( "B_0269", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "1e3 ")
      Show( "B_0270", r )
   RECOVER USING e
      Err( "B_0270", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P009()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "1e3abc")
      Show( "B_0271", r )
   RECOVER USING e
      Err( "B_0271", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "1e3x1")
      Show( "B_0272", r )
   RECOVER USING e
      Err( "B_0272", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "1e3.")
      Show( "B_0273", r )
   RECOVER USING e
      Err( "B_0273", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "1e3")
      Show( "B_0274", r )
   RECOVER USING e
      Err( "B_0274", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "1e3 ")
      Show( "B_0275", r )
   RECOVER USING e
      Err( "B_0275", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "1e3abc")
      Show( "B_0276", r )
   RECOVER USING e
      Err( "B_0276", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "1e3x1")
      Show( "B_0277", r )
   RECOVER USING e
      Err( "B_0277", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "1e3.")
      Show( "B_0278", r )
   RECOVER USING e
      Err( "B_0278", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("7 ")
      Show( "B_0279", r )
   RECOVER USING e
      Err( "B_0279", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("7abc")
      Show( "B_0280", r )
   RECOVER USING e
      Err( "B_0280", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("7x1")
      Show( "B_0281", r )
   RECOVER USING e
      Err( "B_0281", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("7.")
      Show( "B_0282", r )
   RECOVER USING e
      Err( "B_0282", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 7")
      Show( "B_0283", r )
   RECOVER USING e
      Err( "B_0283", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 7 ")
      Show( "B_0284", r )
   RECOVER USING e
      Err( "B_0284", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 7abc")
      Show( "B_0285", r )
   RECOVER USING e
      Err( "B_0285", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 7x1")
      Show( "B_0286", r )
   RECOVER USING e
      Err( "B_0286", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(" 7.")
      Show( "B_0287", r )
   RECOVER USING e
      Err( "B_0287", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  7")
      Show( "B_0288", r )
   RECOVER USING e
      Err( "B_0288", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  7 ")
      Show( "B_0289", r )
   RECOVER USING e
      Err( "B_0289", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  7abc")
      Show( "B_0290", r )
   RECOVER USING e
      Err( "B_0290", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  7x1")
      Show( "B_0291", r )
   RECOVER USING e
      Err( "B_0291", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("  7.")
      Show( "B_0292", r )
   RECOVER USING e
      Err( "B_0292", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "7")
      Show( "B_0293", r )
   RECOVER USING e
      Err( "B_0293", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "7 ")
      Show( "B_0294", r )
   RECOVER USING e
      Err( "B_0294", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "7abc")
      Show( "B_0295", r )
   RECOVER USING e
      Err( "B_0295", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "7x1")
      Show( "B_0296", r )
   RECOVER USING e
      Err( "B_0296", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(9) + "7.")
      Show( "B_0297", r )
   RECOVER USING e
      Err( "B_0297", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "7")
      Show( "B_0298", r )
   RECOVER USING e
      Err( "B_0298", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "7 ")
      Show( "B_0299", r )
   RECOVER USING e
      Err( "B_0299", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "7abc")
      Show( "B_0300", r )
   RECOVER USING e
      Err( "B_0300", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P010()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "7x1")
      Show( "B_0301", r )
   RECOVER USING e
      Err( "B_0301", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(10) + "7.")
      Show( "B_0302", r )
   RECOVER USING e
      Err( "B_0302", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(NIL)
      Show( "C_0303", r )
   RECOVER USING e
      Err( "C_0303", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(5)
      Show( "C_0304", r )
   RECOVER USING e
      Err( "C_0304", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(5.5)
      Show( "C_0305", r )
   RECOVER USING e
      Err( "C_0305", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(-1)
      Show( "C_0306", r )
   RECOVER USING e
      Err( "C_0306", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(0)
      Show( "C_0307", r )
   RECOVER USING e
      Err( "C_0307", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(.T.)
      Show( "C_0308", r )
   RECOVER USING e
      Err( "C_0308", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(.F.)
      Show( "C_0309", r )
   RECOVER USING e
      Err( "C_0309", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val({})
      Show( "C_0310", r )
   RECOVER USING e
      Err( "C_0310", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val({1})
      Show( "C_0311", r )
   RECOVER USING e
      Err( "C_0311", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Date())
      Show( "C_0312", r )
   RECOVER USING e
      Err( "C_0312", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_SToD('20200101'))
      Show( "C_0313", r )
   RECOVER USING e
      Err( "C_0313", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val({||1})
      Show( "C_0314", r )
   RECOVER USING e
      Err( "C_0314", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(5))
      Show( "C_0315", r )
   RECOVER USING e
      Err( "C_0315", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Chr(0))
      Show( "C_0316", r )
   RECOVER USING e
      Err( "C_0316", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Space(5))
      Show( "C_0317", r )
   RECOVER USING e
      Err( "C_0317", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Space(0))
      Show( "C_0318", r )
   RECOVER USING e
      Err( "C_0318", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Replicate('9',50))
      Show( "C_0319", r )
   RECOVER USING e
      Err( "C_0319", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Replicate('1',100))
      Show( "C_0320", r )
   RECOVER USING e
      Err( "C_0320", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Replicate('0',100)+'5')
      Show( "C_0321", r )
   RECOVER USING e
      Err( "C_0321", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val() // ADAPTED: direct call, macro row D_0322
      Show( "D_0322", r )
   RECOVER USING e
      Err( "D_0322", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1","2") // ADAPTED: direct call, macro row D_0323
      Show( "D_0323", r )
   RECOVER USING e
      Err( "D_0323", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1",2,3) // ADAPTED: direct call, macro row D_0324
      Show( "D_0324", r )
   RECOVER USING e
      Err( "D_0324", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(NIL,NIL) // ADAPTED: direct call, macro row D_0325
      Show( "D_0325", r )
   RECOVER USING e
      Err( "D_0325", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")*100
      Show( "E_0326", r )
   RECOVER USING e
      Err( "E_0326", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")*1000
      Show( "E_0327", r )
   RECOVER USING e
      Err( "E_0327", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")+0.1
      Show( "E_0328", r )
   RECOVER USING e
      Err( "E_0328", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")-0.1
      Show( "E_0329", r )
   RECOVER USING e
      Err( "E_0329", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")*3
      Show( "E_0330", r )
   RECOVER USING e
      Err( "E_0330", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P011()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")/3
      Show( "E_0331", r )
   RECOVER USING e
      Err( "E_0331", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")*1
      Show( "E_0332", r )
   RECOVER USING e
      Err( "E_0332", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")+0
      Show( "E_0333", r )
   RECOVER USING e
      Err( "E_0333", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")*0
      Show( "E_0334", r )
   RECOVER USING e
      Err( "E_0334", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")*Val('3')
      Show( "E_0335", r )
   RECOVER USING e
      Err( "E_0335", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")==1.005
      Show( "E_0336", r )
   RECOVER USING e
      Err( "E_0336", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")-1.005
      Show( "E_0337", r )
   RECOVER USING e
      Err( "E_0337", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")*10
      Show( "E_0338", r )
   RECOVER USING e
      Err( "E_0338", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.005")*10.0
      Show( "E_0339", r )
   RECOVER USING e
      Err( "E_0339", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("1.005"),0)
      Show( "E_0340", r )
   RECOVER USING e
      Err( "E_0340", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("1.005")*10^0)
      Show( "E_0341", r )
   RECOVER USING e
      Err( "E_0341", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("1.005"),1)
      Show( "E_0342", r )
   RECOVER USING e
      Err( "E_0342", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("1.005")*10^1)
      Show( "E_0343", r )
   RECOVER USING e
      Err( "E_0343", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("1.005"),2)
      Show( "E_0344", r )
   RECOVER USING e
      Err( "E_0344", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("1.005")*10^2)
      Show( "E_0345", r )
   RECOVER USING e
      Err( "E_0345", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("1.005"),3)
      Show( "E_0346", r )
   RECOVER USING e
      Err( "E_0346", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("1.005")*10^3)
      Show( "E_0347", r )
   RECOVER USING e
      Err( "E_0347", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")*100
      Show( "E_0348", r )
   RECOVER USING e
      Err( "E_0348", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")*1000
      Show( "E_0349", r )
   RECOVER USING e
      Err( "E_0349", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")+0.1
      Show( "E_0350", r )
   RECOVER USING e
      Err( "E_0350", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")-0.1
      Show( "E_0351", r )
   RECOVER USING e
      Err( "E_0351", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")*3
      Show( "E_0352", r )
   RECOVER USING e
      Err( "E_0352", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")/3
      Show( "E_0353", r )
   RECOVER USING e
      Err( "E_0353", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")*1
      Show( "E_0354", r )
   RECOVER USING e
      Err( "E_0354", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")+0
      Show( "E_0355", r )
   RECOVER USING e
      Err( "E_0355", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")*0
      Show( "E_0356", r )
   RECOVER USING e
      Err( "E_0356", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")*Val('3')
      Show( "E_0357", r )
   RECOVER USING e
      Err( "E_0357", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")==2.675
      Show( "E_0358", r )
   RECOVER USING e
      Err( "E_0358", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")-2.675
      Show( "E_0359", r )
   RECOVER USING e
      Err( "E_0359", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")*10
      Show( "E_0360", r )
   RECOVER USING e
      Err( "E_0360", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P012()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("2.675")*10.0
      Show( "E_0361", r )
   RECOVER USING e
      Err( "E_0361", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("2.675"),0)
      Show( "E_0362", r )
   RECOVER USING e
      Err( "E_0362", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("2.675")*10^0)
      Show( "E_0363", r )
   RECOVER USING e
      Err( "E_0363", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("2.675"),1)
      Show( "E_0364", r )
   RECOVER USING e
      Err( "E_0364", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("2.675")*10^1)
      Show( "E_0365", r )
   RECOVER USING e
      Err( "E_0365", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("2.675"),2)
      Show( "E_0366", r )
   RECOVER USING e
      Err( "E_0366", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("2.675")*10^2)
      Show( "E_0367", r )
   RECOVER USING e
      Err( "E_0367", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("2.675"),3)
      Show( "E_0368", r )
   RECOVER USING e
      Err( "E_0368", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("2.675")*10^3)
      Show( "E_0369", r )
   RECOVER USING e
      Err( "E_0369", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")*100
      Show( "E_0370", r )
   RECOVER USING e
      Err( "E_0370", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")*1000
      Show( "E_0371", r )
   RECOVER USING e
      Err( "E_0371", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")+0.1
      Show( "E_0372", r )
   RECOVER USING e
      Err( "E_0372", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")-0.1
      Show( "E_0373", r )
   RECOVER USING e
      Err( "E_0373", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")*3
      Show( "E_0374", r )
   RECOVER USING e
      Err( "E_0374", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")/3
      Show( "E_0375", r )
   RECOVER USING e
      Err( "E_0375", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")*1
      Show( "E_0376", r )
   RECOVER USING e
      Err( "E_0376", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")+0
      Show( "E_0377", r )
   RECOVER USING e
      Err( "E_0377", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")*0
      Show( "E_0378", r )
   RECOVER USING e
      Err( "E_0378", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")*Val('3')
      Show( "E_0379", r )
   RECOVER USING e
      Err( "E_0379", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")==0.285
      Show( "E_0380", r )
   RECOVER USING e
      Err( "E_0380", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")-0.285
      Show( "E_0381", r )
   RECOVER USING e
      Err( "E_0381", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")*10
      Show( "E_0382", r )
   RECOVER USING e
      Err( "E_0382", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.285")*10.0
      Show( "E_0383", r )
   RECOVER USING e
      Err( "E_0383", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.285"),0)
      Show( "E_0384", r )
   RECOVER USING e
      Err( "E_0384", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.285")*10^0)
      Show( "E_0385", r )
   RECOVER USING e
      Err( "E_0385", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.285"),1)
      Show( "E_0386", r )
   RECOVER USING e
      Err( "E_0386", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.285")*10^1)
      Show( "E_0387", r )
   RECOVER USING e
      Err( "E_0387", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.285"),2)
      Show( "E_0388", r )
   RECOVER USING e
      Err( "E_0388", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.285")*10^2)
      Show( "E_0389", r )
   RECOVER USING e
      Err( "E_0389", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.285"),3)
      Show( "E_0390", r )
   RECOVER USING e
      Err( "E_0390", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P013()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.285")*10^3)
      Show( "E_0391", r )
   RECOVER USING e
      Err( "E_0391", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")*100
      Show( "E_0392", r )
   RECOVER USING e
      Err( "E_0392", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")*1000
      Show( "E_0393", r )
   RECOVER USING e
      Err( "E_0393", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")+0.1
      Show( "E_0394", r )
   RECOVER USING e
      Err( "E_0394", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")-0.1
      Show( "E_0395", r )
   RECOVER USING e
      Err( "E_0395", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")*3
      Show( "E_0396", r )
   RECOVER USING e
      Err( "E_0396", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")/3
      Show( "E_0397", r )
   RECOVER USING e
      Err( "E_0397", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")*1
      Show( "E_0398", r )
   RECOVER USING e
      Err( "E_0398", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")+0
      Show( "E_0399", r )
   RECOVER USING e
      Err( "E_0399", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")*0
      Show( "E_0400", r )
   RECOVER USING e
      Err( "E_0400", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")*Val('3')
      Show( "E_0401", r )
   RECOVER USING e
      Err( "E_0401", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")==0.1
      Show( "E_0402", r )
   RECOVER USING e
      Err( "E_0402", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")-0.1
      Show( "E_0403", r )
   RECOVER USING e
      Err( "E_0403", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")*10
      Show( "E_0404", r )
   RECOVER USING e
      Err( "E_0404", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.1")*10.0
      Show( "E_0405", r )
   RECOVER USING e
      Err( "E_0405", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.1"),0)
      Show( "E_0406", r )
   RECOVER USING e
      Err( "E_0406", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.1")*10^0)
      Show( "E_0407", r )
   RECOVER USING e
      Err( "E_0407", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.1"),1)
      Show( "E_0408", r )
   RECOVER USING e
      Err( "E_0408", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.1")*10^1)
      Show( "E_0409", r )
   RECOVER USING e
      Err( "E_0409", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.1"),2)
      Show( "E_0410", r )
   RECOVER USING e
      Err( "E_0410", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.1")*10^2)
      Show( "E_0411", r )
   RECOVER USING e
      Err( "E_0411", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.1"),3)
      Show( "E_0412", r )
   RECOVER USING e
      Err( "E_0412", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.1")*10^3)
      Show( "E_0413", r )
   RECOVER USING e
      Err( "E_0413", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")*100
      Show( "E_0414", r )
   RECOVER USING e
      Err( "E_0414", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")*1000
      Show( "E_0415", r )
   RECOVER USING e
      Err( "E_0415", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")+0.1
      Show( "E_0416", r )
   RECOVER USING e
      Err( "E_0416", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")-0.1
      Show( "E_0417", r )
   RECOVER USING e
      Err( "E_0417", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")*3
      Show( "E_0418", r )
   RECOVER USING e
      Err( "E_0418", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")/3
      Show( "E_0419", r )
   RECOVER USING e
      Err( "E_0419", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")*1
      Show( "E_0420", r )
   RECOVER USING e
      Err( "E_0420", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P014()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")+0
      Show( "E_0421", r )
   RECOVER USING e
      Err( "E_0421", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")*0
      Show( "E_0422", r )
   RECOVER USING e
      Err( "E_0422", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")*Val('3')
      Show( "E_0423", r )
   RECOVER USING e
      Err( "E_0423", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")==0.2
      Show( "E_0424", r )
   RECOVER USING e
      Err( "E_0424", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")-0.2
      Show( "E_0425", r )
   RECOVER USING e
      Err( "E_0425", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")*10
      Show( "E_0426", r )
   RECOVER USING e
      Err( "E_0426", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.2")*10.0
      Show( "E_0427", r )
   RECOVER USING e
      Err( "E_0427", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.2"),0)
      Show( "E_0428", r )
   RECOVER USING e
      Err( "E_0428", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.2")*10^0)
      Show( "E_0429", r )
   RECOVER USING e
      Err( "E_0429", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.2"),1)
      Show( "E_0430", r )
   RECOVER USING e
      Err( "E_0430", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.2")*10^1)
      Show( "E_0431", r )
   RECOVER USING e
      Err( "E_0431", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.2"),2)
      Show( "E_0432", r )
   RECOVER USING e
      Err( "E_0432", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.2")*10^2)
      Show( "E_0433", r )
   RECOVER USING e
      Err( "E_0433", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.2"),3)
      Show( "E_0434", r )
   RECOVER USING e
      Err( "E_0434", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.2")*10^3)
      Show( "E_0435", r )
   RECOVER USING e
      Err( "E_0435", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")*100
      Show( "E_0436", r )
   RECOVER USING e
      Err( "E_0436", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")*1000
      Show( "E_0437", r )
   RECOVER USING e
      Err( "E_0437", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")+0.1
      Show( "E_0438", r )
   RECOVER USING e
      Err( "E_0438", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")-0.1
      Show( "E_0439", r )
   RECOVER USING e
      Err( "E_0439", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")*3
      Show( "E_0440", r )
   RECOVER USING e
      Err( "E_0440", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")/3
      Show( "E_0441", r )
   RECOVER USING e
      Err( "E_0441", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")*1
      Show( "E_0442", r )
   RECOVER USING e
      Err( "E_0442", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")+0
      Show( "E_0443", r )
   RECOVER USING e
      Err( "E_0443", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")*0
      Show( "E_0444", r )
   RECOVER USING e
      Err( "E_0444", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")*Val('3')
      Show( "E_0445", r )
   RECOVER USING e
      Err( "E_0445", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")==1.1
      Show( "E_0446", r )
   RECOVER USING e
      Err( "E_0446", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")-1.1
      Show( "E_0447", r )
   RECOVER USING e
      Err( "E_0447", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")*10
      Show( "E_0448", r )
   RECOVER USING e
      Err( "E_0448", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.1")*10.0
      Show( "E_0449", r )
   RECOVER USING e
      Err( "E_0449", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("1.1"),0)
      Show( "E_0450", r )
   RECOVER USING e
      Err( "E_0450", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P015()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("1.1")*10^0)
      Show( "E_0451", r )
   RECOVER USING e
      Err( "E_0451", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("1.1"),1)
      Show( "E_0452", r )
   RECOVER USING e
      Err( "E_0452", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("1.1")*10^1)
      Show( "E_0453", r )
   RECOVER USING e
      Err( "E_0453", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("1.1"),2)
      Show( "E_0454", r )
   RECOVER USING e
      Err( "E_0454", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("1.1")*10^2)
      Show( "E_0455", r )
   RECOVER USING e
      Err( "E_0455", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("1.1"),3)
      Show( "E_0456", r )
   RECOVER USING e
      Err( "E_0456", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("1.1")*10^3)
      Show( "E_0457", r )
   RECOVER USING e
      Err( "E_0457", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")*100
      Show( "E_0458", r )
   RECOVER USING e
      Err( "E_0458", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")*1000
      Show( "E_0459", r )
   RECOVER USING e
      Err( "E_0459", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")+0.1
      Show( "E_0460", r )
   RECOVER USING e
      Err( "E_0460", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")-0.1
      Show( "E_0461", r )
   RECOVER USING e
      Err( "E_0461", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")*3
      Show( "E_0462", r )
   RECOVER USING e
      Err( "E_0462", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")/3
      Show( "E_0463", r )
   RECOVER USING e
      Err( "E_0463", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")*1
      Show( "E_0464", r )
   RECOVER USING e
      Err( "E_0464", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")+0
      Show( "E_0465", r )
   RECOVER USING e
      Err( "E_0465", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")*0
      Show( "E_0466", r )
   RECOVER USING e
      Err( "E_0466", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")*Val('3')
      Show( "E_0467", r )
   RECOVER USING e
      Err( "E_0467", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")==3.3
      Show( "E_0468", r )
   RECOVER USING e
      Err( "E_0468", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")-3.3
      Show( "E_0469", r )
   RECOVER USING e
      Err( "E_0469", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")*10
      Show( "E_0470", r )
   RECOVER USING e
      Err( "E_0470", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("3.3")*10.0
      Show( "E_0471", r )
   RECOVER USING e
      Err( "E_0471", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("3.3"),0)
      Show( "E_0472", r )
   RECOVER USING e
      Err( "E_0472", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("3.3")*10^0)
      Show( "E_0473", r )
   RECOVER USING e
      Err( "E_0473", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("3.3"),1)
      Show( "E_0474", r )
   RECOVER USING e
      Err( "E_0474", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("3.3")*10^1)
      Show( "E_0475", r )
   RECOVER USING e
      Err( "E_0475", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("3.3"),2)
      Show( "E_0476", r )
   RECOVER USING e
      Err( "E_0476", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("3.3")*10^2)
      Show( "E_0477", r )
   RECOVER USING e
      Err( "E_0477", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("3.3"),3)
      Show( "E_0478", r )
   RECOVER USING e
      Err( "E_0478", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("3.3")*10^3)
      Show( "E_0479", r )
   RECOVER USING e
      Err( "E_0479", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")*100
      Show( "E_0480", r )
   RECOVER USING e
      Err( "E_0480", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P016()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")*1000
      Show( "E_0481", r )
   RECOVER USING e
      Err( "E_0481", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")+0.1
      Show( "E_0482", r )
   RECOVER USING e
      Err( "E_0482", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")-0.1
      Show( "E_0483", r )
   RECOVER USING e
      Err( "E_0483", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")*3
      Show( "E_0484", r )
   RECOVER USING e
      Err( "E_0484", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")/3
      Show( "E_0485", r )
   RECOVER USING e
      Err( "E_0485", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")*1
      Show( "E_0486", r )
   RECOVER USING e
      Err( "E_0486", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")+0
      Show( "E_0487", r )
   RECOVER USING e
      Err( "E_0487", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")*0
      Show( "E_0488", r )
   RECOVER USING e
      Err( "E_0488", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")*Val('3')
      Show( "E_0489", r )
   RECOVER USING e
      Err( "E_0489", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")==0.7
      Show( "E_0490", r )
   RECOVER USING e
      Err( "E_0490", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")-0.7
      Show( "E_0491", r )
   RECOVER USING e
      Err( "E_0491", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")*10
      Show( "E_0492", r )
   RECOVER USING e
      Err( "E_0492", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.7")*10.0
      Show( "E_0493", r )
   RECOVER USING e
      Err( "E_0493", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.7"),0)
      Show( "E_0494", r )
   RECOVER USING e
      Err( "E_0494", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.7")*10^0)
      Show( "E_0495", r )
   RECOVER USING e
      Err( "E_0495", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.7"),1)
      Show( "E_0496", r )
   RECOVER USING e
      Err( "E_0496", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.7")*10^1)
      Show( "E_0497", r )
   RECOVER USING e
      Err( "E_0497", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.7"),2)
      Show( "E_0498", r )
   RECOVER USING e
      Err( "E_0498", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.7")*10^2)
      Show( "E_0499", r )
   RECOVER USING e
      Err( "E_0499", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.7"),3)
      Show( "E_0500", r )
   RECOVER USING e
      Err( "E_0500", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.7")*10^3)
      Show( "E_0501", r )
   RECOVER USING e
      Err( "E_0501", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")*100
      Show( "E_0502", r )
   RECOVER USING e
      Err( "E_0502", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")*1000
      Show( "E_0503", r )
   RECOVER USING e
      Err( "E_0503", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")+0.1
      Show( "E_0504", r )
   RECOVER USING e
      Err( "E_0504", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")-0.1
      Show( "E_0505", r )
   RECOVER USING e
      Err( "E_0505", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")*3
      Show( "E_0506", r )
   RECOVER USING e
      Err( "E_0506", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")/3
      Show( "E_0507", r )
   RECOVER USING e
      Err( "E_0507", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")*1
      Show( "E_0508", r )
   RECOVER USING e
      Err( "E_0508", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")+0
      Show( "E_0509", r )
   RECOVER USING e
      Err( "E_0509", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")*0
      Show( "E_0510", r )
   RECOVER USING e
      Err( "E_0510", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P017()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")*Val('3')
      Show( "E_0511", r )
   RECOVER USING e
      Err( "E_0511", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")==4.35
      Show( "E_0512", r )
   RECOVER USING e
      Err( "E_0512", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")-4.35
      Show( "E_0513", r )
   RECOVER USING e
      Err( "E_0513", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")*10
      Show( "E_0514", r )
   RECOVER USING e
      Err( "E_0514", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("4.35")*10.0
      Show( "E_0515", r )
   RECOVER USING e
      Err( "E_0515", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("4.35"),0)
      Show( "E_0516", r )
   RECOVER USING e
      Err( "E_0516", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("4.35")*10^0)
      Show( "E_0517", r )
   RECOVER USING e
      Err( "E_0517", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("4.35"),1)
      Show( "E_0518", r )
   RECOVER USING e
      Err( "E_0518", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("4.35")*10^1)
      Show( "E_0519", r )
   RECOVER USING e
      Err( "E_0519", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("4.35"),2)
      Show( "E_0520", r )
   RECOVER USING e
      Err( "E_0520", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("4.35")*10^2)
      Show( "E_0521", r )
   RECOVER USING e
      Err( "E_0521", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("4.35"),3)
      Show( "E_0522", r )
   RECOVER USING e
      Err( "E_0522", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("4.35")*10^3)
      Show( "E_0523", r )
   RECOVER USING e
      Err( "E_0523", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")*100
      Show( "E_0524", r )
   RECOVER USING e
      Err( "E_0524", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")*1000
      Show( "E_0525", r )
   RECOVER USING e
      Err( "E_0525", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")+0.1
      Show( "E_0526", r )
   RECOVER USING e
      Err( "E_0526", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")-0.1
      Show( "E_0527", r )
   RECOVER USING e
      Err( "E_0527", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")*3
      Show( "E_0528", r )
   RECOVER USING e
      Err( "E_0528", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")/3
      Show( "E_0529", r )
   RECOVER USING e
      Err( "E_0529", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")*1
      Show( "E_0530", r )
   RECOVER USING e
      Err( "E_0530", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")+0
      Show( "E_0531", r )
   RECOVER USING e
      Err( "E_0531", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")*0
      Show( "E_0532", r )
   RECOVER USING e
      Err( "E_0532", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")*Val('3')
      Show( "E_0533", r )
   RECOVER USING e
      Err( "E_0533", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")==1.15
      Show( "E_0534", r )
   RECOVER USING e
      Err( "E_0534", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")-1.15
      Show( "E_0535", r )
   RECOVER USING e
      Err( "E_0535", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")*10
      Show( "E_0536", r )
   RECOVER USING e
      Err( "E_0536", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1.15")*10.0
      Show( "E_0537", r )
   RECOVER USING e
      Err( "E_0537", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("1.15"),0)
      Show( "E_0538", r )
   RECOVER USING e
      Err( "E_0538", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("1.15")*10^0)
      Show( "E_0539", r )
   RECOVER USING e
      Err( "E_0539", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("1.15"),1)
      Show( "E_0540", r )
   RECOVER USING e
      Err( "E_0540", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P018()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("1.15")*10^1)
      Show( "E_0541", r )
   RECOVER USING e
      Err( "E_0541", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("1.15"),2)
      Show( "E_0542", r )
   RECOVER USING e
      Err( "E_0542", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("1.15")*10^2)
      Show( "E_0543", r )
   RECOVER USING e
      Err( "E_0543", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("1.15"),3)
      Show( "E_0544", r )
   RECOVER USING e
      Err( "E_0544", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("1.15")*10^3)
      Show( "E_0545", r )
   RECOVER USING e
      Err( "E_0545", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")*100
      Show( "E_0546", r )
   RECOVER USING e
      Err( "E_0546", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")*1000
      Show( "E_0547", r )
   RECOVER USING e
      Err( "E_0547", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")+0.1
      Show( "E_0548", r )
   RECOVER USING e
      Err( "E_0548", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")-0.1
      Show( "E_0549", r )
   RECOVER USING e
      Err( "E_0549", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")*3
      Show( "E_0550", r )
   RECOVER USING e
      Err( "E_0550", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")/3
      Show( "E_0551", r )
   RECOVER USING e
      Err( "E_0551", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")*1
      Show( "E_0552", r )
   RECOVER USING e
      Err( "E_0552", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")+0
      Show( "E_0553", r )
   RECOVER USING e
      Err( "E_0553", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")*0
      Show( "E_0554", r )
   RECOVER USING e
      Err( "E_0554", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")*Val('3')
      Show( "E_0555", r )
   RECOVER USING e
      Err( "E_0555", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")==8.2
      Show( "E_0556", r )
   RECOVER USING e
      Err( "E_0556", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")-8.2
      Show( "E_0557", r )
   RECOVER USING e
      Err( "E_0557", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")*10
      Show( "E_0558", r )
   RECOVER USING e
      Err( "E_0558", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("8.2")*10.0
      Show( "E_0559", r )
   RECOVER USING e
      Err( "E_0559", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("8.2"),0)
      Show( "E_0560", r )
   RECOVER USING e
      Err( "E_0560", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("8.2")*10^0)
      Show( "E_0561", r )
   RECOVER USING e
      Err( "E_0561", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("8.2"),1)
      Show( "E_0562", r )
   RECOVER USING e
      Err( "E_0562", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("8.2")*10^1)
      Show( "E_0563", r )
   RECOVER USING e
      Err( "E_0563", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("8.2"),2)
      Show( "E_0564", r )
   RECOVER USING e
      Err( "E_0564", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("8.2")*10^2)
      Show( "E_0565", r )
   RECOVER USING e
      Err( "E_0565", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("8.2"),3)
      Show( "E_0566", r )
   RECOVER USING e
      Err( "E_0566", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("8.2")*10^3)
      Show( "E_0567", r )
   RECOVER USING e
      Err( "E_0567", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")*100
      Show( "E_0568", r )
   RECOVER USING e
      Err( "E_0568", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")*1000
      Show( "E_0569", r )
   RECOVER USING e
      Err( "E_0569", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")+0.1
      Show( "E_0570", r )
   RECOVER USING e
      Err( "E_0570", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P019()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")-0.1
      Show( "E_0571", r )
   RECOVER USING e
      Err( "E_0571", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")*3
      Show( "E_0572", r )
   RECOVER USING e
      Err( "E_0572", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")/3
      Show( "E_0573", r )
   RECOVER USING e
      Err( "E_0573", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")*1
      Show( "E_0574", r )
   RECOVER USING e
      Err( "E_0574", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")+0
      Show( "E_0575", r )
   RECOVER USING e
      Err( "E_0575", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")*0
      Show( "E_0576", r )
   RECOVER USING e
      Err( "E_0576", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")*Val('3')
      Show( "E_0577", r )
   RECOVER USING e
      Err( "E_0577", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")==0.57
      Show( "E_0578", r )
   RECOVER USING e
      Err( "E_0578", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")-0.57
      Show( "E_0579", r )
   RECOVER USING e
      Err( "E_0579", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")*10
      Show( "E_0580", r )
   RECOVER USING e
      Err( "E_0580", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("0.57")*10.0
      Show( "E_0581", r )
   RECOVER USING e
      Err( "E_0581", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.57"),0)
      Show( "E_0582", r )
   RECOVER USING e
      Err( "E_0582", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.57")*10^0)
      Show( "E_0583", r )
   RECOVER USING e
      Err( "E_0583", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.57"),1)
      Show( "E_0584", r )
   RECOVER USING e
      Err( "E_0584", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.57")*10^1)
      Show( "E_0585", r )
   RECOVER USING e
      Err( "E_0585", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.57"),2)
      Show( "E_0586", r )
   RECOVER USING e
      Err( "E_0586", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.57")*10^2)
      Show( "E_0587", r )
   RECOVER USING e
      Err( "E_0587", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("0.57"),3)
      Show( "E_0588", r )
   RECOVER USING e
      Err( "E_0588", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("0.57")*10^3)
      Show( "E_0589", r )
   RECOVER USING e
      Err( "E_0589", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")*100
      Show( "E_0590", r )
   RECOVER USING e
      Err( "E_0590", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")*1000
      Show( "E_0591", r )
   RECOVER USING e
      Err( "E_0591", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")+0.1
      Show( "E_0592", r )
   RECOVER USING e
      Err( "E_0592", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")-0.1
      Show( "E_0593", r )
   RECOVER USING e
      Err( "E_0593", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")*3
      Show( "E_0594", r )
   RECOVER USING e
      Err( "E_0594", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")/3
      Show( "E_0595", r )
   RECOVER USING e
      Err( "E_0595", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")*1
      Show( "E_0596", r )
   RECOVER USING e
      Err( "E_0596", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")+0
      Show( "E_0597", r )
   RECOVER USING e
      Err( "E_0597", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")*0
      Show( "E_0598", r )
   RECOVER USING e
      Err( "E_0598", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")*Val('3')
      Show( "E_0599", r )
   RECOVER USING e
      Err( "E_0599", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")==19.99
      Show( "E_0600", r )
   RECOVER USING e
      Err( "E_0600", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P020()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")-19.99
      Show( "E_0601", r )
   RECOVER USING e
      Err( "E_0601", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")*10
      Show( "E_0602", r )
   RECOVER USING e
      Err( "E_0602", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("19.99")*10.0
      Show( "E_0603", r )
   RECOVER USING e
      Err( "E_0603", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("19.99"),0)
      Show( "E_0604", r )
   RECOVER USING e
      Err( "E_0604", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("19.99")*10^0)
      Show( "E_0605", r )
   RECOVER USING e
      Err( "E_0605", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("19.99"),1)
      Show( "E_0606", r )
   RECOVER USING e
      Err( "E_0606", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("19.99")*10^1)
      Show( "E_0607", r )
   RECOVER USING e
      Err( "E_0607", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("19.99"),2)
      Show( "E_0608", r )
   RECOVER USING e
      Err( "E_0608", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("19.99")*10^2)
      Show( "E_0609", r )
   RECOVER USING e
      Err( "E_0609", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("19.99"),3)
      Show( "E_0610", r )
   RECOVER USING e
      Err( "E_0610", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("19.99")*10^3)
      Show( "E_0611", r )
   RECOVER USING e
      Err( "E_0611", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")*100
      Show( "E_0612", r )
   RECOVER USING e
      Err( "E_0612", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")*1000
      Show( "E_0613", r )
   RECOVER USING e
      Err( "E_0613", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")+0.1
      Show( "E_0614", r )
   RECOVER USING e
      Err( "E_0614", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")-0.1
      Show( "E_0615", r )
   RECOVER USING e
      Err( "E_0615", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")*3
      Show( "E_0616", r )
   RECOVER USING e
      Err( "E_0616", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")/3
      Show( "E_0617", r )
   RECOVER USING e
      Err( "E_0617", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")*1
      Show( "E_0618", r )
   RECOVER USING e
      Err( "E_0618", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")+0
      Show( "E_0619", r )
   RECOVER USING e
      Err( "E_0619", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")*0
      Show( "E_0620", r )
   RECOVER USING e
      Err( "E_0620", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")*Val('3')
      Show( "E_0621", r )
   RECOVER USING e
      Err( "E_0621", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")==100.005
      Show( "E_0622", r )
   RECOVER USING e
      Err( "E_0622", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")-100.005
      Show( "E_0623", r )
   RECOVER USING e
      Err( "E_0623", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")*10
      Show( "E_0624", r )
   RECOVER USING e
      Err( "E_0624", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("100.005")*10.0
      Show( "E_0625", r )
   RECOVER USING e
      Err( "E_0625", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("100.005"),0)
      Show( "E_0626", r )
   RECOVER USING e
      Err( "E_0626", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("100.005")*10^0)
      Show( "E_0627", r )
   RECOVER USING e
      Err( "E_0627", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("100.005"),1)
      Show( "E_0628", r )
   RECOVER USING e
      Err( "E_0628", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("100.005")*10^1)
      Show( "E_0629", r )
   RECOVER USING e
      Err( "E_0629", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("100.005"),2)
      Show( "E_0630", r )
   RECOVER USING e
      Err( "E_0630", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P021()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("100.005")*10^2)
      Show( "E_0631", r )
   RECOVER USING e
      Err( "E_0631", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("100.005"),3)
      Show( "E_0632", r )
   RECOVER USING e
      Err( "E_0632", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("100.005")*10^3)
      Show( "E_0633", r )
   RECOVER USING e
      Err( "E_0633", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")*100
      Show( "E_0634", r )
   RECOVER USING e
      Err( "E_0634", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")*1000
      Show( "E_0635", r )
   RECOVER USING e
      Err( "E_0635", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")+0.1
      Show( "E_0636", r )
   RECOVER USING e
      Err( "E_0636", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")-0.1
      Show( "E_0637", r )
   RECOVER USING e
      Err( "E_0637", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")*3
      Show( "E_0638", r )
   RECOVER USING e
      Err( "E_0638", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")/3
      Show( "E_0639", r )
   RECOVER USING e
      Err( "E_0639", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")*1
      Show( "E_0640", r )
   RECOVER USING e
      Err( "E_0640", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")+0
      Show( "E_0641", r )
   RECOVER USING e
      Err( "E_0641", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")*0
      Show( "E_0642", r )
   RECOVER USING e
      Err( "E_0642", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")*Val('3')
      Show( "E_0643", r )
   RECOVER USING e
      Err( "E_0643", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")==999999999999999.5
      Show( "E_0644", r )
   RECOVER USING e
      Err( "E_0644", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")-999999999999999.5
      Show( "E_0645", r )
   RECOVER USING e
      Err( "E_0645", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")*10
      Show( "E_0646", r )
   RECOVER USING e
      Err( "E_0646", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("999999999999999.5")*10.0
      Show( "E_0647", r )
   RECOVER USING e
      Err( "E_0647", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("999999999999999.5"),0)
      Show( "E_0648", r )
   RECOVER USING e
      Err( "E_0648", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("999999999999999.5")*10^0)
      Show( "E_0649", r )
   RECOVER USING e
      Err( "E_0649", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("999999999999999.5"),1)
      Show( "E_0650", r )
   RECOVER USING e
      Err( "E_0650", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("999999999999999.5")*10^1)
      Show( "E_0651", r )
   RECOVER USING e
      Err( "E_0651", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("999999999999999.5"),2)
      Show( "E_0652", r )
   RECOVER USING e
      Err( "E_0652", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("999999999999999.5")*10^2)
      Show( "E_0653", r )
   RECOVER USING e
      Err( "E_0653", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("999999999999999.5"),3)
      Show( "E_0654", r )
   RECOVER USING e
      Err( "E_0654", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("999999999999999.5")*10^3)
      Show( "E_0655", r )
   RECOVER USING e
      Err( "E_0655", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")*100
      Show( "E_0656", r )
   RECOVER USING e
      Err( "E_0656", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")*1000
      Show( "E_0657", r )
   RECOVER USING e
      Err( "E_0657", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")+0.1
      Show( "E_0658", r )
   RECOVER USING e
      Err( "E_0658", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")-0.1
      Show( "E_0659", r )
   RECOVER USING e
      Err( "E_0659", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")*3
      Show( "E_0660", r )
   RECOVER USING e
      Err( "E_0660", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P022()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")/3
      Show( "E_0661", r )
   RECOVER USING e
      Err( "E_0661", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")*1
      Show( "E_0662", r )
   RECOVER USING e
      Err( "E_0662", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")+0
      Show( "E_0663", r )
   RECOVER USING e
      Err( "E_0663", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")*0
      Show( "E_0664", r )
   RECOVER USING e
      Err( "E_0664", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")*Val('3')
      Show( "E_0665", r )
   RECOVER USING e
      Err( "E_0665", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")==123456789012345.67
      Show( "E_0666", r )
   RECOVER USING e
      Err( "E_0666", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")-123456789012345.67
      Show( "E_0667", r )
   RECOVER USING e
      Err( "E_0667", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")*10
      Show( "E_0668", r )
   RECOVER USING e
      Err( "E_0668", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("123456789012345.67")*10.0
      Show( "E_0669", r )
   RECOVER USING e
      Err( "E_0669", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("123456789012345.67"),0)
      Show( "E_0670", r )
   RECOVER USING e
      Err( "E_0670", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("123456789012345.67")*10^0)
      Show( "E_0671", r )
   RECOVER USING e
      Err( "E_0671", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("123456789012345.67"),1)
      Show( "E_0672", r )
   RECOVER USING e
      Err( "E_0672", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("123456789012345.67")*10^1)
      Show( "E_0673", r )
   RECOVER USING e
      Err( "E_0673", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("123456789012345.67"),2)
      Show( "E_0674", r )
   RECOVER USING e
      Err( "E_0674", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("123456789012345.67")*10^2)
      Show( "E_0675", r )
   RECOVER USING e
      Err( "E_0675", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Round(Val("123456789012345.67"),3)
      Show( "E_0676", r )
   RECOVER USING e
      Err( "E_0676", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Int(Val("123456789012345.67")*10^3)
      Show( "E_0677", r )
   RECOVER USING e
      Err( "E_0677", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.1')+Val('0.2')
      Show( "E_0678", r )
   RECOVER USING e
      Err( "E_0678", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.1')+Val('0.2')==Val('0.3')
      Show( "E_0679", r )
   RECOVER USING e
      Err( "E_0679", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.1')+Val('0.2')-Val('0.3')
      Show( "E_0680", r )
   RECOVER USING e
      Err( "E_0680", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,10,2))
      Show( "F_0681", r )
   RECOVER USING e
      Err( "F_0681", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,10,0))
      Show( "F_0682", r )
   RECOVER USING e
      Err( "F_0682", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,8,3))
      Show( "F_0683", r )
   RECOVER USING e
      Err( "F_0683", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,20,10))
      Show( "F_0684", r )
   RECOVER USING e
      Err( "F_0684", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,30,15))
      Show( "F_0685", r )
   RECOVER USING e
      Err( "F_0685", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,34,17))
      Show( "F_0686", r )
   RECOVER USING e
      Err( "F_0686", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,5,1))
      Show( "F_0687", r )
   RECOVER USING e
      Err( "F_0687", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,12,6))
      Show( "F_0688", r )
   RECOVER USING e
      Err( "F_0688", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,0,0))
      Show( "F_0689", r )
   RECOVER USING e
      Err( "F_0689", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005))
      Show( "F_0690", r )
   RECOVER USING e
      Err( "F_0690", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P023()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1.005,20))
      Show( "F_0691", r )
   RECOVER USING e
      Err( "F_0691", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(1.005))
      Show( "F_0692", r )
   RECOVER USING e
      Err( "F_0692", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(1.005))
      Show( "F_0693", r )
   RECOVER USING e
      Err( "F_0693", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,10,2))
      Show( "F_0694", r )
   RECOVER USING e
      Err( "F_0694", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,10,0))
      Show( "F_0695", r )
   RECOVER USING e
      Err( "F_0695", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,8,3))
      Show( "F_0696", r )
   RECOVER USING e
      Err( "F_0696", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,20,10))
      Show( "F_0697", r )
   RECOVER USING e
      Err( "F_0697", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,30,15))
      Show( "F_0698", r )
   RECOVER USING e
      Err( "F_0698", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,34,17))
      Show( "F_0699", r )
   RECOVER USING e
      Err( "F_0699", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,5,1))
      Show( "F_0700", r )
   RECOVER USING e
      Err( "F_0700", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,12,6))
      Show( "F_0701", r )
   RECOVER USING e
      Err( "F_0701", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,0,0))
      Show( "F_0702", r )
   RECOVER USING e
      Err( "F_0702", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675))
      Show( "F_0703", r )
   RECOVER USING e
      Err( "F_0703", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2.675,20))
      Show( "F_0704", r )
   RECOVER USING e
      Err( "F_0704", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(2.675))
      Show( "F_0705", r )
   RECOVER USING e
      Err( "F_0705", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(2.675))
      Show( "F_0706", r )
   RECOVER USING e
      Err( "F_0706", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,10,2))
      Show( "F_0707", r )
   RECOVER USING e
      Err( "F_0707", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,10,0))
      Show( "F_0708", r )
   RECOVER USING e
      Err( "F_0708", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,8,3))
      Show( "F_0709", r )
   RECOVER USING e
      Err( "F_0709", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,20,10))
      Show( "F_0710", r )
   RECOVER USING e
      Err( "F_0710", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,30,15))
      Show( "F_0711", r )
   RECOVER USING e
      Err( "F_0711", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,34,17))
      Show( "F_0712", r )
   RECOVER USING e
      Err( "F_0712", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,5,1))
      Show( "F_0713", r )
   RECOVER USING e
      Err( "F_0713", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,12,6))
      Show( "F_0714", r )
   RECOVER USING e
      Err( "F_0714", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,0,0))
      Show( "F_0715", r )
   RECOVER USING e
      Err( "F_0715", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285))
      Show( "F_0716", r )
   RECOVER USING e
      Err( "F_0716", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.285,20))
      Show( "F_0717", r )
   RECOVER USING e
      Err( "F_0717", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(0.285))
      Show( "F_0718", r )
   RECOVER USING e
      Err( "F_0718", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(0.285))
      Show( "F_0719", r )
   RECOVER USING e
      Err( "F_0719", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,10,2))
      Show( "F_0720", r )
   RECOVER USING e
      Err( "F_0720", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P024()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,10,0))
      Show( "F_0721", r )
   RECOVER USING e
      Err( "F_0721", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,8,3))
      Show( "F_0722", r )
   RECOVER USING e
      Err( "F_0722", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,20,10))
      Show( "F_0723", r )
   RECOVER USING e
      Err( "F_0723", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,30,15))
      Show( "F_0724", r )
   RECOVER USING e
      Err( "F_0724", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,34,17))
      Show( "F_0725", r )
   RECOVER USING e
      Err( "F_0725", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,5,1))
      Show( "F_0726", r )
   RECOVER USING e
      Err( "F_0726", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,12,6))
      Show( "F_0727", r )
   RECOVER USING e
      Err( "F_0727", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,0,0))
      Show( "F_0728", r )
   RECOVER USING e
      Err( "F_0728", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456))
      Show( "F_0729", r )
   RECOVER USING e
      Err( "F_0729", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123.456,20))
      Show( "F_0730", r )
   RECOVER USING e
      Err( "F_0730", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(123.456))
      Show( "F_0731", r )
   RECOVER USING e
      Err( "F_0731", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(123.456))
      Show( "F_0732", r )
   RECOVER USING e
      Err( "F_0732", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(-7.25,10,2))
      Show( "F_0733", r )
   RECOVER USING e
      Err( "F_0733", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(-7.25,10,0))
      Show( "F_0734", r )
   RECOVER USING e
      Err( "F_0734", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(-7.25,8,3))
      Show( "F_0735", r )
   RECOVER USING e
      Err( "F_0735", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(-7.25,20,10))
      Show( "F_0736", r )
   RECOVER USING e
      Err( "F_0736", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(-7.25,30,15))
      Show( "F_0737", r )
   RECOVER USING e
      Err( "F_0737", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(-7.25,34,17))
      Show( "F_0738", r )
   RECOVER USING e
      Err( "F_0738", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(-7.25,5,1))
      Show( "F_0739", r )
   RECOVER USING e
      Err( "F_0739", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(-7.25,12,6))
      Show( "F_0740", r )
   RECOVER USING e
      Err( "F_0740", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(-7.25,0,0))
      Show( "F_0741", r )
   RECOVER USING e
      Err( "F_0741", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(-7.25))
      Show( "F_0742", r )
   RECOVER USING e
      Err( "F_0742", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(-7.25,20))
      Show( "F_0743", r )
   RECOVER USING e
      Err( "F_0743", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(-7.25))
      Show( "F_0744", r )
   RECOVER USING e
      Err( "F_0744", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(-7.25))
      Show( "F_0745", r )
   RECOVER USING e
      Err( "F_0745", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.1,10,2))
      Show( "F_0746", r )
   RECOVER USING e
      Err( "F_0746", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.1,10,0))
      Show( "F_0747", r )
   RECOVER USING e
      Err( "F_0747", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.1,8,3))
      Show( "F_0748", r )
   RECOVER USING e
      Err( "F_0748", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.1,20,10))
      Show( "F_0749", r )
   RECOVER USING e
      Err( "F_0749", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.1,30,15))
      Show( "F_0750", r )
   RECOVER USING e
      Err( "F_0750", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P025()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.1,34,17))
      Show( "F_0751", r )
   RECOVER USING e
      Err( "F_0751", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.1,5,1))
      Show( "F_0752", r )
   RECOVER USING e
      Err( "F_0752", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.1,12,6))
      Show( "F_0753", r )
   RECOVER USING e
      Err( "F_0753", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.1,0,0))
      Show( "F_0754", r )
   RECOVER USING e
      Err( "F_0754", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.1))
      Show( "F_0755", r )
   RECOVER USING e
      Err( "F_0755", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.1,20))
      Show( "F_0756", r )
   RECOVER USING e
      Err( "F_0756", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(0.1))
      Show( "F_0757", r )
   RECOVER USING e
      Err( "F_0757", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(0.1))
      Show( "F_0758", r )
   RECOVER USING e
      Err( "F_0758", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000,10,2))
      Show( "F_0759", r )
   RECOVER USING e
      Err( "F_0759", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000,10,0))
      Show( "F_0760", r )
   RECOVER USING e
      Err( "F_0760", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000,8,3))
      Show( "F_0761", r )
   RECOVER USING e
      Err( "F_0761", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000,20,10))
      Show( "F_0762", r )
   RECOVER USING e
      Err( "F_0762", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000,30,15))
      Show( "F_0763", r )
   RECOVER USING e
      Err( "F_0763", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000,34,17))
      Show( "F_0764", r )
   RECOVER USING e
      Err( "F_0764", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000,5,1))
      Show( "F_0765", r )
   RECOVER USING e
      Err( "F_0765", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000,12,6))
      Show( "F_0766", r )
   RECOVER USING e
      Err( "F_0766", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000,0,0))
      Show( "F_0767", r )
   RECOVER USING e
      Err( "F_0767", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000))
      Show( "F_0768", r )
   RECOVER USING e
      Err( "F_0768", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1000000000000000,20))
      Show( "F_0769", r )
   RECOVER USING e
      Err( "F_0769", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(1000000000000000))
      Show( "F_0770", r )
   RECOVER USING e
      Err( "F_0770", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(1000000000000000))
      Show( "F_0771", r )
   RECOVER USING e
      Err( "F_0771", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123456789.123456789,10,2))
      Show( "F_0772", r )
   RECOVER USING e
      Err( "F_0772", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123456789.123456789,10,0))
      Show( "F_0773", r )
   RECOVER USING e
      Err( "F_0773", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123456789.123456789,8,3))
      Show( "F_0774", r )
   RECOVER USING e
      Err( "F_0774", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123456789.123456789,20,10))
      Show( "F_0775", r )
   RECOVER USING e
      Err( "F_0775", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123456789.123456789,30,15))
      Show( "F_0776", r )
   RECOVER USING e
      Err( "F_0776", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123456789.123456789,34,17))
      Show( "F_0777", r )
   RECOVER USING e
      Err( "F_0777", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123456789.123456789,5,1))
      Show( "F_0778", r )
   RECOVER USING e
      Err( "F_0778", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123456789.123456789,12,6))
      Show( "F_0779", r )
   RECOVER USING e
      Err( "F_0779", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123456789.123456789,0,0))
      Show( "F_0780", r )
   RECOVER USING e
      Err( "F_0780", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P026()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123456789.123456789))
      Show( "F_0781", r )
   RECOVER USING e
      Err( "F_0781", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(123456789.123456789,20))
      Show( "F_0782", r )
   RECOVER USING e
      Err( "F_0782", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(123456789.123456789))
      Show( "F_0783", r )
   RECOVER USING e
      Err( "F_0783", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(123456789.123456789))
      Show( "F_0784", r )
   RECOVER USING e
      Err( "F_0784", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.99,10,2))
      Show( "F_0785", r )
   RECOVER USING e
      Err( "F_0785", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.99,10,0))
      Show( "F_0786", r )
   RECOVER USING e
      Err( "F_0786", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.99,8,3))
      Show( "F_0787", r )
   RECOVER USING e
      Err( "F_0787", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.99,20,10))
      Show( "F_0788", r )
   RECOVER USING e
      Err( "F_0788", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.99,30,15))
      Show( "F_0789", r )
   RECOVER USING e
      Err( "F_0789", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.99,34,17))
      Show( "F_0790", r )
   RECOVER USING e
      Err( "F_0790", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.99,5,1))
      Show( "F_0791", r )
   RECOVER USING e
      Err( "F_0791", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.99,12,6))
      Show( "F_0792", r )
   RECOVER USING e
      Err( "F_0792", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.99,0,0))
      Show( "F_0793", r )
   RECOVER USING e
      Err( "F_0793", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.99))
      Show( "F_0794", r )
   RECOVER USING e
      Err( "F_0794", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(99.99,20))
      Show( "F_0795", r )
   RECOVER USING e
      Err( "F_0795", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(99.99))
      Show( "F_0796", r )
   RECOVER USING e
      Err( "F_0796", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(99.99))
      Show( "F_0797", r )
   RECOVER USING e
      Err( "F_0797", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,10,2))
      Show( "F_0798", r )
   RECOVER USING e
      Err( "F_0798", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,10,0))
      Show( "F_0799", r )
   RECOVER USING e
      Err( "F_0799", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,8,3))
      Show( "F_0800", r )
   RECOVER USING e
      Err( "F_0800", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,20,10))
      Show( "F_0801", r )
   RECOVER USING e
      Err( "F_0801", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,30,15))
      Show( "F_0802", r )
   RECOVER USING e
      Err( "F_0802", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,34,17))
      Show( "F_0803", r )
   RECOVER USING e
      Err( "F_0803", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,5,1))
      Show( "F_0804", r )
   RECOVER USING e
      Err( "F_0804", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,12,6))
      Show( "F_0805", r )
   RECOVER USING e
      Err( "F_0805", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,0,0))
      Show( "F_0806", r )
   RECOVER USING e
      Err( "F_0806", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5))
      Show( "F_0807", r )
   RECOVER USING e
      Err( "F_0807", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(0.5,20))
      Show( "F_0808", r )
   RECOVER USING e
      Err( "F_0808", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(0.5))
      Show( "F_0809", r )
   RECOVER USING e
      Err( "F_0809", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(0.5))
      Show( "F_0810", r )
   RECOVER USING e
      Err( "F_0810", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P027()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1/3,10,2))
      Show( "F_0811", r )
   RECOVER USING e
      Err( "F_0811", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1/3,10,0))
      Show( "F_0812", r )
   RECOVER USING e
      Err( "F_0812", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1/3,8,3))
      Show( "F_0813", r )
   RECOVER USING e
      Err( "F_0813", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1/3,20,10))
      Show( "F_0814", r )
   RECOVER USING e
      Err( "F_0814", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1/3,30,15))
      Show( "F_0815", r )
   RECOVER USING e
      Err( "F_0815", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1/3,34,17))
      Show( "F_0816", r )
   RECOVER USING e
      Err( "F_0816", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1/3,5,1))
      Show( "F_0817", r )
   RECOVER USING e
      Err( "F_0817", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1/3,12,6))
      Show( "F_0818", r )
   RECOVER USING e
      Err( "F_0818", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1/3,0,0))
      Show( "F_0819", r )
   RECOVER USING e
      Err( "F_0819", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1/3))
      Show( "F_0820", r )
   RECOVER USING e
      Err( "F_0820", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(1/3,20))
      Show( "F_0821", r )
   RECOVER USING e
      Err( "F_0821", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(1/3))
      Show( "F_0822", r )
   RECOVER USING e
      Err( "F_0822", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(1/3))
      Show( "F_0823", r )
   RECOVER USING e
      Err( "F_0823", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2/3,10,2))
      Show( "F_0824", r )
   RECOVER USING e
      Err( "F_0824", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2/3,10,0))
      Show( "F_0825", r )
   RECOVER USING e
      Err( "F_0825", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2/3,8,3))
      Show( "F_0826", r )
   RECOVER USING e
      Err( "F_0826", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2/3,20,10))
      Show( "F_0827", r )
   RECOVER USING e
      Err( "F_0827", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2/3,30,15))
      Show( "F_0828", r )
   RECOVER USING e
      Err( "F_0828", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2/3,34,17))
      Show( "F_0829", r )
   RECOVER USING e
      Err( "F_0829", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2/3,5,1))
      Show( "F_0830", r )
   RECOVER USING e
      Err( "F_0830", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2/3,12,6))
      Show( "F_0831", r )
   RECOVER USING e
      Err( "F_0831", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2/3,0,0))
      Show( "F_0832", r )
   RECOVER USING e
      Err( "F_0832", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2/3))
      Show( "F_0833", r )
   RECOVER USING e
      Err( "F_0833", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(2/3,20))
      Show( "F_0834", r )
   RECOVER USING e
      Err( "F_0834", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(2/3))
      Show( "F_0835", r )
   RECOVER USING e
      Err( "F_0835", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(2/3))
      Show( "F_0836", r )
   RECOVER USING e
      Err( "F_0836", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(10/3,10,2))
      Show( "F_0837", r )
   RECOVER USING e
      Err( "F_0837", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(10/3,10,0))
      Show( "F_0838", r )
   RECOVER USING e
      Err( "F_0838", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(10/3,8,3))
      Show( "F_0839", r )
   RECOVER USING e
      Err( "F_0839", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(10/3,20,10))
      Show( "F_0840", r )
   RECOVER USING e
      Err( "F_0840", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P028()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(10/3,30,15))
      Show( "F_0841", r )
   RECOVER USING e
      Err( "F_0841", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(10/3,34,17))
      Show( "F_0842", r )
   RECOVER USING e
      Err( "F_0842", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(10/3,5,1))
      Show( "F_0843", r )
   RECOVER USING e
      Err( "F_0843", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(10/3,12,6))
      Show( "F_0844", r )
   RECOVER USING e
      Err( "F_0844", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(10/3,0,0))
      Show( "F_0845", r )
   RECOVER USING e
      Err( "F_0845", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(10/3))
      Show( "F_0846", r )
   RECOVER USING e
      Err( "F_0846", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(10/3,20))
      Show( "F_0847", r )
   RECOVER USING e
      Err( "F_0847", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(10/3))
      Show( "F_0848", r )
   RECOVER USING e
      Err( "F_0848", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(10/3))
      Show( "F_0849", r )
   RECOVER USING e
      Err( "F_0849", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(Sqrt(2),10,2))
      Show( "F_0850", r )
   RECOVER USING e
      Err( "F_0850", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(Sqrt(2),10,0))
      Show( "F_0851", r )
   RECOVER USING e
      Err( "F_0851", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(Sqrt(2),8,3))
      Show( "F_0852", r )
   RECOVER USING e
      Err( "F_0852", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(Sqrt(2),20,10))
      Show( "F_0853", r )
   RECOVER USING e
      Err( "F_0853", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(Sqrt(2),30,15))
      Show( "F_0854", r )
   RECOVER USING e
      Err( "F_0854", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(Sqrt(2),34,17))
      Show( "F_0855", r )
   RECOVER USING e
      Err( "F_0855", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(Sqrt(2),5,1))
      Show( "F_0856", r )
   RECOVER USING e
      Err( "F_0856", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(Sqrt(2),12,6))
      Show( "F_0857", r )
   RECOVER USING e
      Err( "F_0857", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(Sqrt(2),0,0))
      Show( "F_0858", r )
   RECOVER USING e
      Err( "F_0858", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(Sqrt(2)))
      Show( "F_0859", r )
   RECOVER USING e
      Err( "F_0859", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(Sqrt(2),20))
      Show( "F_0860", r )
   RECOVER USING e
      Err( "F_0860", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(Sqrt(2)))
      Show( "F_0861", r )
   RECOVER USING e
      Err( "F_0861", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(Sqrt(2)))
      Show( "F_0862", r )
   RECOVER USING e
      Err( "F_0862", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(3.141592653589793,10,2))
      Show( "F_0863", r )
   RECOVER USING e
      Err( "F_0863", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(3.141592653589793,10,0))
      Show( "F_0864", r )
   RECOVER USING e
      Err( "F_0864", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(3.141592653589793,8,3))
      Show( "F_0865", r )
   RECOVER USING e
      Err( "F_0865", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(3.141592653589793,20,10))
      Show( "F_0866", r )
   RECOVER USING e
      Err( "F_0866", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(3.141592653589793,30,15))
      Show( "F_0867", r )
   RECOVER USING e
      Err( "F_0867", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(3.141592653589793,34,17))
      Show( "F_0868", r )
   RECOVER USING e
      Err( "F_0868", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(3.141592653589793,5,1))
      Show( "F_0869", r )
   RECOVER USING e
      Err( "F_0869", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(3.141592653589793,12,6))
      Show( "F_0870", r )
   RECOVER USING e
      Err( "F_0870", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P029()
   LOCAL r, e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(3.141592653589793,0,0))
      Show( "F_0871", r )
   RECOVER USING e
      Err( "F_0871", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(3.141592653589793))
      Show( "F_0872", r )
   RECOVER USING e
      Err( "F_0872", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(Str(3.141592653589793,20))
      Show( "F_0873", r )
   RECOVER USING e
      Err( "F_0873", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_ntos(3.141592653589793))
      Show( "F_0874", r )
   RECOVER USING e
      Err( "F_0874", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val(hb_CStr(3.141592653589793))
      Show( "F_0875", r )
   RECOVER USING e
      Err( "F_0875", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE PS()
   LOCAL r, e
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.005')
      Show( "O_0876", r )
   RECOVER USING e
      Err( "O_0876", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('2.675')
      Show( "O_0877", r )
   RECOVER USING e
      Err( "O_0877", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.285')
      Show( "O_0878", r )
   RECOVER USING e
      Err( "O_0878", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1')
      Show( "O_0879", r )
   RECOVER USING e
      Err( "O_0879", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.5e3')
      Show( "O_0880", r )
   RECOVER USING e
      Err( "O_0880", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.1234567890123')
      Show( "O_0881", r )
   RECOVER USING e
      Err( "O_0881", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12345678901234567890')
      Show( "O_0882", r )
   RECOVER USING e
      Err( "O_0882", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.50')
      Show( "O_0883", r )
   RECOVER USING e
      Err( "O_0883", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('3.14159265358979')
      Show( "O_0884", r )
   RECOVER USING e
      Err( "O_0884", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.0000001')
      Show( "O_0885", r )
   RECOVER USING e
      Err( "O_0885", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('-0.5')
      Show( "O_0886", r )
   RECOVER USING e
      Err( "O_0886", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12abc')
      Show( "O_0887", r )
   RECOVER USING e
      Err( "O_0887", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.005')
      Show( "O_0888", r )
   RECOVER USING e
      Err( "O_0888", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('2.675')
      Show( "O_0889", r )
   RECOVER USING e
      Err( "O_0889", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.285')
      Show( "O_0890", r )
   RECOVER USING e
      Err( "O_0890", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1')
      Show( "O_0891", r )
   RECOVER USING e
      Err( "O_0891", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.5e3')
      Show( "O_0892", r )
   RECOVER USING e
      Err( "O_0892", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.1234567890123')
      Show( "O_0893", r )
   RECOVER USING e
      Err( "O_0893", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12345678901234567890')
      Show( "O_0894", r )
   RECOVER USING e
      Err( "O_0894", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.50')
      Show( "O_0895", r )
   RECOVER USING e
      Err( "O_0895", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('3.14159265358979')
      Show( "O_0896", r )
   RECOVER USING e
      Err( "O_0896", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.0000001')
      Show( "O_0897", r )
   RECOVER USING e
      Err( "O_0897", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('-0.5')
      Show( "O_0898", r )
   RECOVER USING e
      Err( "O_0898", e )
   END SEQUENCE
   SET DECIMALS TO 0
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12abc')
      Show( "O_0899", r )
   RECOVER USING e
      Err( "O_0899", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.005')
      Show( "O_0900", r )
   RECOVER USING e
      Err( "O_0900", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('2.675')
      Show( "O_0901", r )
   RECOVER USING e
      Err( "O_0901", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.285')
      Show( "O_0902", r )
   RECOVER USING e
      Err( "O_0902", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1')
      Show( "O_0903", r )
   RECOVER USING e
      Err( "O_0903", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.5e3')
      Show( "O_0904", r )
   RECOVER USING e
      Err( "O_0904", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.1234567890123')
      Show( "O_0905", r )
   RECOVER USING e
      Err( "O_0905", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12345678901234567890')
      Show( "O_0906", r )
   RECOVER USING e
      Err( "O_0906", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.50')
      Show( "O_0907", r )
   RECOVER USING e
      Err( "O_0907", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('3.14159265358979')
      Show( "O_0908", r )
   RECOVER USING e
      Err( "O_0908", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.0000001')
      Show( "O_0909", r )
   RECOVER USING e
      Err( "O_0909", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('-0.5')
      Show( "O_0910", r )
   RECOVER USING e
      Err( "O_0910", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12abc')
      Show( "O_0911", r )
   RECOVER USING e
      Err( "O_0911", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.005')
      Show( "O_0912", r )
   RECOVER USING e
      Err( "O_0912", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('2.675')
      Show( "O_0913", r )
   RECOVER USING e
      Err( "O_0913", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.285')
      Show( "O_0914", r )
   RECOVER USING e
      Err( "O_0914", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1')
      Show( "O_0915", r )
   RECOVER USING e
      Err( "O_0915", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.5e3')
      Show( "O_0916", r )
   RECOVER USING e
      Err( "O_0916", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.1234567890123')
      Show( "O_0917", r )
   RECOVER USING e
      Err( "O_0917", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12345678901234567890')
      Show( "O_0918", r )
   RECOVER USING e
      Err( "O_0918", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.50')
      Show( "O_0919", r )
   RECOVER USING e
      Err( "O_0919", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('3.14159265358979')
      Show( "O_0920", r )
   RECOVER USING e
      Err( "O_0920", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.0000001')
      Show( "O_0921", r )
   RECOVER USING e
      Err( "O_0921", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('-0.5')
      Show( "O_0922", r )
   RECOVER USING e
      Err( "O_0922", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12abc')
      Show( "O_0923", r )
   RECOVER USING e
      Err( "O_0923", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.005')
      Show( "O_0924", r )
   RECOVER USING e
      Err( "O_0924", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('2.675')
      Show( "O_0925", r )
   RECOVER USING e
      Err( "O_0925", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.285')
      Show( "O_0926", r )
   RECOVER USING e
      Err( "O_0926", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1')
      Show( "O_0927", r )
   RECOVER USING e
      Err( "O_0927", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.5e3')
      Show( "O_0928", r )
   RECOVER USING e
      Err( "O_0928", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.1234567890123')
      Show( "O_0929", r )
   RECOVER USING e
      Err( "O_0929", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12345678901234567890')
      Show( "O_0930", r )
   RECOVER USING e
      Err( "O_0930", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.50')
      Show( "O_0931", r )
   RECOVER USING e
      Err( "O_0931", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('3.14159265358979')
      Show( "O_0932", r )
   RECOVER USING e
      Err( "O_0932", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.0000001')
      Show( "O_0933", r )
   RECOVER USING e
      Err( "O_0933", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('-0.5')
      Show( "O_0934", r )
   RECOVER USING e
      Err( "O_0934", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12abc')
      Show( "O_0935", r )
   RECOVER USING e
      Err( "O_0935", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.005')
      Show( "O_0936", r )
   RECOVER USING e
      Err( "O_0936", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('2.675')
      Show( "O_0937", r )
   RECOVER USING e
      Err( "O_0937", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.285')
      Show( "O_0938", r )
   RECOVER USING e
      Err( "O_0938", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1')
      Show( "O_0939", r )
   RECOVER USING e
      Err( "O_0939", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.5e3')
      Show( "O_0940", r )
   RECOVER USING e
      Err( "O_0940", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.1234567890123')
      Show( "O_0941", r )
   RECOVER USING e
      Err( "O_0941", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12345678901234567890')
      Show( "O_0942", r )
   RECOVER USING e
      Err( "O_0942", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.50')
      Show( "O_0943", r )
   RECOVER USING e
      Err( "O_0943", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('3.14159265358979')
      Show( "O_0944", r )
   RECOVER USING e
      Err( "O_0944", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.0000001')
      Show( "O_0945", r )
   RECOVER USING e
      Err( "O_0945", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('-0.5')
      Show( "O_0946", r )
   RECOVER USING e
      Err( "O_0946", e )
   END SEQUENCE
   SET DECIMALS TO 5
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12abc')
      Show( "O_0947", r )
   RECOVER USING e
      Err( "O_0947", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.005')
      Show( "O_0948", r )
   RECOVER USING e
      Err( "O_0948", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('2.675')
      Show( "O_0949", r )
   RECOVER USING e
      Err( "O_0949", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.285')
      Show( "O_0950", r )
   RECOVER USING e
      Err( "O_0950", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1')
      Show( "O_0951", r )
   RECOVER USING e
      Err( "O_0951", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.5e3')
      Show( "O_0952", r )
   RECOVER USING e
      Err( "O_0952", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.1234567890123')
      Show( "O_0953", r )
   RECOVER USING e
      Err( "O_0953", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12345678901234567890')
      Show( "O_0954", r )
   RECOVER USING e
      Err( "O_0954", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.50')
      Show( "O_0955", r )
   RECOVER USING e
      Err( "O_0955", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('3.14159265358979')
      Show( "O_0956", r )
   RECOVER USING e
      Err( "O_0956", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.0000001')
      Show( "O_0957", r )
   RECOVER USING e
      Err( "O_0957", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('-0.5')
      Show( "O_0958", r )
   RECOVER USING e
      Err( "O_0958", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED OFF
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12abc')
      Show( "O_0959", r )
   RECOVER USING e
      Err( "O_0959", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.005')
      Show( "O_0960", r )
   RECOVER USING e
      Err( "O_0960", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('2.675')
      Show( "O_0961", r )
   RECOVER USING e
      Err( "O_0961", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.285')
      Show( "O_0962", r )
   RECOVER USING e
      Err( "O_0962", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1')
      Show( "O_0963", r )
   RECOVER USING e
      Err( "O_0963", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.5e3')
      Show( "O_0964", r )
   RECOVER USING e
      Err( "O_0964", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.1234567890123')
      Show( "O_0965", r )
   RECOVER USING e
      Err( "O_0965", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12345678901234567890')
      Show( "O_0966", r )
   RECOVER USING e
      Err( "O_0966", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('1.50')
      Show( "O_0967", r )
   RECOVER USING e
      Err( "O_0967", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('3.14159265358979')
      Show( "O_0968", r )
   RECOVER USING e
      Err( "O_0968", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('0.0000001')
      Show( "O_0969", r )
   RECOVER USING e
      Err( "O_0969", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('-0.5')
      Show( "O_0970", r )
   RECOVER USING e
      Err( "O_0970", e )
   END SEQUENCE
   SET DECIMALS TO 10
   SET FIXED ON
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val('12abc')
      Show( "O_0971", r )
   RECOVER USING e
      Err( "O_0971", e )
   END SEQUENCE
   SET DECIMALS TO 2
   SET FIXED OFF
   RETURN

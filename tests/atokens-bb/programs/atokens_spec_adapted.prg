// hb_ATokens clean-room black-box spec (adapted harness).
// Oracle: atokens-oracle-spec (spec tgz sha256
// 61379fbbcc25b0a677281d09f73c8c35675771677a7c88aa26d6c8f14e58c0b3;
// 1650 cases; the oracle function is hb_ATokens - plain ATokens does not
// exist in Harbour 3.2.0). This program is the oracle's atokens_spec.prg
// with five LABELLED adaptations (search "ADAPTED"); the original spec
// files are untouched in the tgz. Expected output: the oracle's out.txt
// minus row D_1644 (see adaptation 3), byte-pinned by check.sh.
//
// Adaptation 1: Esc() - no hb_NumToHex in this runtime; manual hex
//   nibble table + Int() wrappers so Chr()/SubStr() get integers. Same
//   output bytes (literal double backslash, x, two UPPERCASE hex).
// Adaptation 2: four macro rows written as direct calls; omitted
//   arguments written as explicit NIL (Harbour's meaning of omission).
// Adaptation 3: row D_1644 (macro ATokens("a b") -> Harbour runtime
//   "Undefined function") removed: HarbourRust has no plain ATokens
//   builtin, so the equivalent guarantee is a COMPILE-TIME named
//   rejection, pinned by rejects/atokens_reject_undef.prg.
// Adaptation 4: Show() array branch inlined per case (array-view
//   parameters are not in this increment; every success row in the
//   oracle output is an "A" row, so the non-array branch is dead here).
//   The element copy is reseated before NEXT because Esc() moves it.
// Adaptation 5: Err() - no error-object system; the caught value IS its
//   description string and is COMPARED against "Argument error" (the
//   only description the oracle reports); operation/subCode/genCode are
//   literal stand-ins, not verified.
STATIC FUNCTION Esc( s )
   // ADAPTED (atokens harness adaptation 1): hb_NumToHex replaced by a
   // manual hex-nibble table; Int() wrappers so Chr()/SubStr() get
   // accepts it. Same output bytes as the oracle harness.
   LOCAL i, c, o := ""
   FOR i := 1 TO Len( s )
      c := Int( Asc( SubStr( s, i, 1 ) ) )
      IF c >= 32 .AND. c < 127 .AND. c != 92
         o += Chr( Int( c ) )
      ELSE
         o += "\\x" + SubStr( "0123456789ABCDEF", Int( c / 16 ) + 1, 1 ) + SubStr( "0123456789ABCDEF", Int( c - Int( c / 16 ) * 16 ) + 1, 1 )
      ENDIF
   NEXT
   RETURN o
// ADAPTED: Show() inlined per case (array-view parameters are not
// in this increment); only its "A" branch existed in the oracle output.
STATIC PROCEDURE Err( id, e )
   // ADAPTED (atokens harness adaptation 5): the captured value is
   // checked, not assumed - it must equal "Argument error", the one
   // description the oracle reports for every hb_ATokens error row.
   // Fields 2-4 are literal stand-ins: this runtime's caught value
   // carries no operation/subCode/genCode.
   LOCAL d := hb_CStr( e )
   IF d == "Argument error"
      OutStd( id + "|ERR|Argument error|HB_ATOKENS|      1123|         1" + hb_eol() )
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
   RETURN
STATIC PROCEDURE P000()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("")
      o := "A_0001|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0001", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", NIL, .F.)
      o := "A_0002|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0002", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", NIL, .T.)
      o := "A_0003|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0003", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", NIL, .T., .T.)
      o := "A_0004|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0004", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", NIL, .T., .F.)
      o := "A_0005|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0005", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", " ")
      o := "A_0006|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0006", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", " ", .F.)
      o := "A_0007|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0007", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", " ", .T.)
      o := "A_0008|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0008", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", " ", .T., .T.)
      o := "A_0009|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0009", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", " ", .T., .F.)
      o := "A_0010|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0010", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ",")
      o := "A_0011|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0011", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ",", .F.)
      o := "A_0012|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0012", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ",", .T.)
      o := "A_0013|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0013", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ",", .T., .T.)
      o := "A_0014|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0014", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ",", .T., .F.)
      o := "A_0015|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0015", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ", ")
      o := "A_0016|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0016", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ", ", .F.)
      o := "A_0017|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0017", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ", ", .T.)
      o := "A_0018|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0018", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ", ", .T., .T.)
      o := "A_0019|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0019", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ", ", .T., .F.)
      o := "A_0020|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0020", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ";")
      o := "A_0021|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0021", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ";", .F.)
      o := "A_0022|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0022", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ";", .T.)
      o := "A_0023|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0023", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ";", .T., .T.)
      o := "A_0024|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0024", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", ";", .T., .F.)
      o := "A_0025|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0025", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", "::")
      o := "A_0026|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0026", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", "::", .F.)
      o := "A_0027|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0027", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", "::", .T.)
      o := "A_0028|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0028", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", "::", .T., .T.)
      o := "A_0029|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0029", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", "::", .T., .F.)
      o := "A_0030|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0030", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P001()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", "")
      o := "A_0031|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0031", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", "", .F.)
      o := "A_0032|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0032", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", "", .T.)
      o := "A_0033|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0033", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", "", .T., .T.)
      o := "A_0034|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0034", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("", "", .T., .F.)
      o := "A_0035|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0035", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ")
      o := "A_0036|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0036", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", NIL, .F.)
      o := "A_0037|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0037", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", NIL, .T.)
      o := "A_0038|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0038", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", NIL, .T., .T.)
      o := "A_0039|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0039", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", NIL, .T., .F.)
      o := "A_0040|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0040", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", " ")
      o := "A_0041|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0041", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", " ", .F.)
      o := "A_0042|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0042", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", " ", .T.)
      o := "A_0043|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0043", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", " ", .T., .T.)
      o := "A_0044|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0044", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", " ", .T., .F.)
      o := "A_0045|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0045", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ",")
      o := "A_0046|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0046", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ",", .F.)
      o := "A_0047|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0047", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ",", .T.)
      o := "A_0048|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0048", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ",", .T., .T.)
      o := "A_0049|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0049", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ",", .T., .F.)
      o := "A_0050|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0050", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ", ")
      o := "A_0051|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0051", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ", ", .F.)
      o := "A_0052|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0052", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ", ", .T.)
      o := "A_0053|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0053", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ", ", .T., .T.)
      o := "A_0054|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0054", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ", ", .T., .F.)
      o := "A_0055|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0055", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ";")
      o := "A_0056|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0056", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ";", .F.)
      o := "A_0057|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0057", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ";", .T.)
      o := "A_0058|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0058", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ";", .T., .T.)
      o := "A_0059|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0059", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", ";", .T., .F.)
      o := "A_0060|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0060", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P002()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", "::")
      o := "A_0061|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0061", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", "::", .F.)
      o := "A_0062|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0062", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", "::", .T.)
      o := "A_0063|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0063", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", "::", .T., .T.)
      o := "A_0064|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0064", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", "::", .T., .F.)
      o := "A_0065|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0065", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", "")
      o := "A_0066|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0066", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", "", .F.)
      o := "A_0067|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0067", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", "", .T.)
      o := "A_0068|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0068", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", "", .T., .T.)
      o := "A_0069|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0069", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  ", "", .T., .F.)
      o := "A_0070|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0070", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ")
      o := "A_0071|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0071", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", NIL, .F.)
      o := "A_0072|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0072", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", NIL, .T.)
      o := "A_0073|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0073", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", NIL, .T., .T.)
      o := "A_0074|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0074", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", NIL, .T., .F.)
      o := "A_0075|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0075", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", " ")
      o := "A_0076|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0076", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", " ", .F.)
      o := "A_0077|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0077", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", " ", .T.)
      o := "A_0078|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0078", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", " ", .T., .T.)
      o := "A_0079|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0079", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", " ", .T., .F.)
      o := "A_0080|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0080", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ",")
      o := "A_0081|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0081", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ",", .F.)
      o := "A_0082|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0082", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ",", .T.)
      o := "A_0083|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0083", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ",", .T., .T.)
      o := "A_0084|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0084", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ",", .T., .F.)
      o := "A_0085|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0085", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ", ")
      o := "A_0086|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0086", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ", ", .F.)
      o := "A_0087|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0087", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ", ", .T.)
      o := "A_0088|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0088", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ", ", .T., .T.)
      o := "A_0089|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0089", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ", ", .T., .F.)
      o := "A_0090|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0090", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P003()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ";")
      o := "A_0091|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0091", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ";", .F.)
      o := "A_0092|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0092", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ";", .T.)
      o := "A_0093|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0093", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ";", .T., .T.)
      o := "A_0094|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0094", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", ";", .T., .F.)
      o := "A_0095|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0095", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", "::")
      o := "A_0096|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0096", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", "::", .F.)
      o := "A_0097|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0097", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", "::", .T.)
      o := "A_0098|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0098", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", "::", .T., .T.)
      o := "A_0099|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0099", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", "::", .T., .F.)
      o := "A_0100|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0100", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", "")
      o := "A_0101|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0101", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", "", .F.)
      o := "A_0102|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0102", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", "", .T.)
      o := "A_0103|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0103", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", "", .T., .T.)
      o := "A_0104|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0104", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(" ", "", .T., .F.)
      o := "A_0105|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0105", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a")
      o := "A_0106|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0106", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", NIL, .F.)
      o := "A_0107|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0107", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", NIL, .T.)
      o := "A_0108|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0108", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", NIL, .T., .T.)
      o := "A_0109|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0109", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", NIL, .T., .F.)
      o := "A_0110|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0110", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", " ")
      o := "A_0111|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0111", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", " ", .F.)
      o := "A_0112|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0112", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", " ", .T.)
      o := "A_0113|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0113", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", " ", .T., .T.)
      o := "A_0114|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0114", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", " ", .T., .F.)
      o := "A_0115|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0115", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ",")
      o := "A_0116|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0116", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ",", .F.)
      o := "A_0117|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0117", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ",", .T.)
      o := "A_0118|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0118", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ",", .T., .T.)
      o := "A_0119|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0119", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ",", .T., .F.)
      o := "A_0120|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0120", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P004()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ", ")
      o := "A_0121|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0121", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ", ", .F.)
      o := "A_0122|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0122", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ", ", .T.)
      o := "A_0123|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0123", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ", ", .T., .T.)
      o := "A_0124|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0124", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ", ", .T., .F.)
      o := "A_0125|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0125", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ";")
      o := "A_0126|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0126", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ";", .F.)
      o := "A_0127|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0127", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ";", .T.)
      o := "A_0128|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0128", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ";", .T., .T.)
      o := "A_0129|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0129", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", ";", .T., .F.)
      o := "A_0130|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0130", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", "::")
      o := "A_0131|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0131", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", "::", .F.)
      o := "A_0132|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0132", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", "::", .T.)
      o := "A_0133|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0133", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", "::", .T., .T.)
      o := "A_0134|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0134", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", "::", .T., .F.)
      o := "A_0135|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0135", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", "")
      o := "A_0136|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0136", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", "", .F.)
      o := "A_0137|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0137", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", "", .T.)
      o := "A_0138|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0138", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", "", .T., .T.)
      o := "A_0139|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0139", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a", "", .T., .F.)
      o := "A_0140|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0140", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b")
      o := "A_0141|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0141", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", NIL, .F.)
      o := "A_0142|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0142", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", NIL, .T.)
      o := "A_0143|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0143", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", NIL, .T., .T.)
      o := "A_0144|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0144", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", NIL, .T., .F.)
      o := "A_0145|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0145", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", " ")
      o := "A_0146|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0146", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", " ", .F.)
      o := "A_0147|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0147", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", " ", .T.)
      o := "A_0148|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0148", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", " ", .T., .T.)
      o := "A_0149|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0149", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", " ", .T., .F.)
      o := "A_0150|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0150", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P005()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ",")
      o := "A_0151|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0151", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ",", .F.)
      o := "A_0152|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0152", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ",", .T.)
      o := "A_0153|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0153", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ",", .T., .T.)
      o := "A_0154|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0154", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ",", .T., .F.)
      o := "A_0155|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0155", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ", ")
      o := "A_0156|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0156", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ", ", .F.)
      o := "A_0157|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0157", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ", ", .T.)
      o := "A_0158|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0158", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ", ", .T., .T.)
      o := "A_0159|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0159", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ", ", .T., .F.)
      o := "A_0160|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0160", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ";")
      o := "A_0161|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0161", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ";", .F.)
      o := "A_0162|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0162", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ";", .T.)
      o := "A_0163|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0163", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ";", .T., .T.)
      o := "A_0164|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0164", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", ";", .T., .F.)
      o := "A_0165|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0165", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", "::")
      o := "A_0166|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0166", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", "::", .F.)
      o := "A_0167|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0167", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", "::", .T.)
      o := "A_0168|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0168", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", "::", .T., .T.)
      o := "A_0169|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0169", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", "::", .T., .F.)
      o := "A_0170|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0170", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", "")
      o := "A_0171|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0171", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", "", .F.)
      o := "A_0172|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0172", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", "", .T.)
      o := "A_0173|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0173", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", "", .T., .T.)
      o := "A_0174|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0174", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b", "", .T., .F.)
      o := "A_0175|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0175", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c")
      o := "A_0176|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0176", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", NIL, .F.)
      o := "A_0177|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0177", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", NIL, .T.)
      o := "A_0178|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0178", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", NIL, .T., .T.)
      o := "A_0179|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0179", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", NIL, .T., .F.)
      o := "A_0180|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0180", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P006()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", " ")
      o := "A_0181|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0181", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", " ", .F.)
      o := "A_0182|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0182", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", " ", .T.)
      o := "A_0183|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0183", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", " ", .T., .T.)
      o := "A_0184|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0184", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", " ", .T., .F.)
      o := "A_0185|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0185", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ",")
      o := "A_0186|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0186", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ",", .F.)
      o := "A_0187|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0187", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ",", .T.)
      o := "A_0188|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0188", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ",", .T., .T.)
      o := "A_0189|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0189", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ",", .T., .F.)
      o := "A_0190|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0190", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ", ")
      o := "A_0191|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0191", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ", ", .F.)
      o := "A_0192|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0192", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ", ", .T.)
      o := "A_0193|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0193", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ", ", .T., .T.)
      o := "A_0194|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0194", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ", ", .T., .F.)
      o := "A_0195|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0195", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ";")
      o := "A_0196|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0196", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ";", .F.)
      o := "A_0197|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0197", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ";", .T.)
      o := "A_0198|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0198", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ";", .T., .T.)
      o := "A_0199|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0199", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", ";", .T., .F.)
      o := "A_0200|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0200", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", "::")
      o := "A_0201|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0201", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", "::", .F.)
      o := "A_0202|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0202", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", "::", .T.)
      o := "A_0203|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0203", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", "::", .T., .T.)
      o := "A_0204|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0204", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", "::", .T., .F.)
      o := "A_0205|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0205", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", "")
      o := "A_0206|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0206", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", "", .F.)
      o := "A_0207|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0207", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", "", .T.)
      o := "A_0208|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0208", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", "", .T., .T.)
      o := "A_0209|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0209", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c", "", .T., .F.)
      o := "A_0210|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0210", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P007()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ")
      o := "A_0211|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0211", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", NIL, .F.)
      o := "A_0212|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0212", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", NIL, .T.)
      o := "A_0213|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0213", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", NIL, .T., .T.)
      o := "A_0214|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0214", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", NIL, .T., .F.)
      o := "A_0215|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0215", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", " ")
      o := "A_0216|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0216", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", " ", .F.)
      o := "A_0217|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0217", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", " ", .T.)
      o := "A_0218|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0218", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", " ", .T., .T.)
      o := "A_0219|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0219", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", " ", .T., .F.)
      o := "A_0220|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0220", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ",")
      o := "A_0221|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0221", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ",", .F.)
      o := "A_0222|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0222", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ",", .T.)
      o := "A_0223|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0223", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ",", .T., .T.)
      o := "A_0224|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0224", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ",", .T., .F.)
      o := "A_0225|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0225", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ", ")
      o := "A_0226|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0226", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ", ", .F.)
      o := "A_0227|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0227", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ", ", .T.)
      o := "A_0228|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0228", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ", ", .T., .T.)
      o := "A_0229|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0229", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ", ", .T., .F.)
      o := "A_0230|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0230", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ";")
      o := "A_0231|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0231", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ";", .F.)
      o := "A_0232|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0232", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ";", .T.)
      o := "A_0233|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0233", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ";", .T., .T.)
      o := "A_0234|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0234", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", ";", .T., .F.)
      o := "A_0235|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0235", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", "::")
      o := "A_0236|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0236", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", "::", .F.)
      o := "A_0237|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0237", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", "::", .T.)
      o := "A_0238|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0238", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", "::", .T., .T.)
      o := "A_0239|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0239", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", "::", .T., .F.)
      o := "A_0240|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0240", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P008()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", "")
      o := "A_0241|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0241", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", "", .F.)
      o := "A_0242|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0242", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", "", .T.)
      o := "A_0243|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0243", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", "", .T., .T.)
      o := "A_0244|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0244", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("  a b  ", "", .T., .F.)
      o := "A_0245|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0245", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c")
      o := "A_0246|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0246", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", NIL, .F.)
      o := "A_0247|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0247", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", NIL, .T.)
      o := "A_0248|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0248", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", NIL, .T., .T.)
      o := "A_0249|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0249", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", NIL, .T., .F.)
      o := "A_0250|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0250", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", " ")
      o := "A_0251|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0251", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", " ", .F.)
      o := "A_0252|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0252", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", " ", .T.)
      o := "A_0253|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0253", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", " ", .T., .T.)
      o := "A_0254|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0254", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", " ", .T., .F.)
      o := "A_0255|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0255", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ",")
      o := "A_0256|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0256", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ",", .F.)
      o := "A_0257|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0257", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ",", .T.)
      o := "A_0258|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0258", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ",", .T., .T.)
      o := "A_0259|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0259", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ",", .T., .F.)
      o := "A_0260|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0260", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ", ")
      o := "A_0261|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0261", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ", ", .F.)
      o := "A_0262|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0262", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ", ", .T.)
      o := "A_0263|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0263", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ", ", .T., .T.)
      o := "A_0264|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0264", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ", ", .T., .F.)
      o := "A_0265|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0265", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ";")
      o := "A_0266|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0266", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ";", .F.)
      o := "A_0267|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0267", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ";", .T.)
      o := "A_0268|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0268", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ";", .T., .T.)
      o := "A_0269|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0269", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", ";", .T., .F.)
      o := "A_0270|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0270", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P009()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", "::")
      o := "A_0271|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0271", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", "::", .F.)
      o := "A_0272|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0272", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", "::", .T.)
      o := "A_0273|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0273", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", "::", .T., .T.)
      o := "A_0274|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0274", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", "::", .T., .F.)
      o := "A_0275|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0275", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", "")
      o := "A_0276|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0276", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", "", .F.)
      o := "A_0277|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0277", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", "", .T.)
      o := "A_0278|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0278", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", "", .T., .T.)
      o := "A_0279|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0279", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c", "", .T., .F.)
      o := "A_0280|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0280", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,")
      o := "A_0281|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0281", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", NIL, .F.)
      o := "A_0282|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0282", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", NIL, .T.)
      o := "A_0283|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0283", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", NIL, .T., .T.)
      o := "A_0284|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0284", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", NIL, .T., .F.)
      o := "A_0285|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0285", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", " ")
      o := "A_0286|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0286", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", " ", .F.)
      o := "A_0287|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0287", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", " ", .T.)
      o := "A_0288|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0288", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", " ", .T., .T.)
      o := "A_0289|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0289", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", " ", .T., .F.)
      o := "A_0290|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0290", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ",")
      o := "A_0291|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0291", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ",", .F.)
      o := "A_0292|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0292", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ",", .T.)
      o := "A_0293|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0293", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ",", .T., .T.)
      o := "A_0294|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0294", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ",", .T., .F.)
      o := "A_0295|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0295", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ", ")
      o := "A_0296|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0296", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ", ", .F.)
      o := "A_0297|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0297", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ", ", .T.)
      o := "A_0298|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0298", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ", ", .T., .T.)
      o := "A_0299|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0299", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ", ", .T., .F.)
      o := "A_0300|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0300", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P010()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ";")
      o := "A_0301|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0301", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ";", .F.)
      o := "A_0302|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0302", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ";", .T.)
      o := "A_0303|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0303", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ";", .T., .T.)
      o := "A_0304|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0304", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", ";", .T., .F.)
      o := "A_0305|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0305", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", "::")
      o := "A_0306|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0306", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", "::", .F.)
      o := "A_0307|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0307", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", "::", .T.)
      o := "A_0308|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0308", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", "::", .T., .T.)
      o := "A_0309|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0309", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", "::", .T., .F.)
      o := "A_0310|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0310", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", "")
      o := "A_0311|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0311", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", "", .F.)
      o := "A_0312|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0312", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", "", .T.)
      o := "A_0313|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0313", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", "", .T., .T.)
      o := "A_0314|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0314", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",a,b,", "", .T., .F.)
      o := "A_0315|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0315", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",")
      o := "A_0316|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0316", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", NIL, .F.)
      o := "A_0317|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0317", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", NIL, .T.)
      o := "A_0318|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0318", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", NIL, .T., .T.)
      o := "A_0319|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0319", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", NIL, .T., .F.)
      o := "A_0320|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0320", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", " ")
      o := "A_0321|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0321", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", " ", .F.)
      o := "A_0322|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0322", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", " ", .T.)
      o := "A_0323|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0323", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", " ", .T., .T.)
      o := "A_0324|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0324", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", " ", .T., .F.)
      o := "A_0325|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0325", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ",")
      o := "A_0326|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0326", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ",", .F.)
      o := "A_0327|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0327", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ",", .T.)
      o := "A_0328|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0328", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ",", .T., .T.)
      o := "A_0329|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0329", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ",", .T., .F.)
      o := "A_0330|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0330", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P011()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ", ")
      o := "A_0331|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0331", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ", ", .F.)
      o := "A_0332|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0332", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ", ", .T.)
      o := "A_0333|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0333", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ", ", .T., .T.)
      o := "A_0334|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0334", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ", ", .T., .F.)
      o := "A_0335|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0335", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ";")
      o := "A_0336|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0336", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ";", .F.)
      o := "A_0337|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0337", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ";", .T.)
      o := "A_0338|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0338", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ";", .T., .T.)
      o := "A_0339|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0339", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", ";", .T., .F.)
      o := "A_0340|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0340", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", "::")
      o := "A_0341|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0341", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", "::", .F.)
      o := "A_0342|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0342", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", "::", .T.)
      o := "A_0343|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0343", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", "::", .T., .T.)
      o := "A_0344|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0344", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", "::", .T., .F.)
      o := "A_0345|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0345", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", "")
      o := "A_0346|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0346", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", "", .F.)
      o := "A_0347|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0347", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", "", .T.)
      o := "A_0348|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0348", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", "", .T., .T.)
      o := "A_0349|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0349", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",", "", .T., .F.)
      o := "A_0350|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0350", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,")
      o := "A_0351|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0351", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", NIL, .F.)
      o := "A_0352|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0352", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", NIL, .T.)
      o := "A_0353|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0353", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", NIL, .T., .T.)
      o := "A_0354|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0354", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", NIL, .T., .F.)
      o := "A_0355|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0355", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", " ")
      o := "A_0356|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0356", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", " ", .F.)
      o := "A_0357|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0357", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", " ", .T.)
      o := "A_0358|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0358", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", " ", .T., .T.)
      o := "A_0359|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0359", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", " ", .T., .F.)
      o := "A_0360|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0360", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P012()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ",")
      o := "A_0361|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0361", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ",", .F.)
      o := "A_0362|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0362", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ",", .T.)
      o := "A_0363|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0363", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ",", .T., .T.)
      o := "A_0364|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0364", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ",", .T., .F.)
      o := "A_0365|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0365", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ", ")
      o := "A_0366|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0366", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ", ", .F.)
      o := "A_0367|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0367", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ", ", .T.)
      o := "A_0368|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0368", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ", ", .T., .T.)
      o := "A_0369|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0369", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ", ", .T., .F.)
      o := "A_0370|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0370", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ";")
      o := "A_0371|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0371", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ";", .F.)
      o := "A_0372|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0372", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ";", .T.)
      o := "A_0373|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0373", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ";", .T., .T.)
      o := "A_0374|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0374", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", ";", .T., .F.)
      o := "A_0375|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0375", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", "::")
      o := "A_0376|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0376", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", "::", .F.)
      o := "A_0377|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0377", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", "::", .T.)
      o := "A_0378|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0378", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", "::", .T., .T.)
      o := "A_0379|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0379", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", "::", .T., .F.)
      o := "A_0380|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0380", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", "")
      o := "A_0381|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0381", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", "", .F.)
      o := "A_0382|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0382", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", "", .T.)
      o := "A_0383|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0383", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", "", .T., .T.)
      o := "A_0384|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0384", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(",,", "", .T., .F.)
      o := "A_0385|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0385", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c")
      o := "A_0386|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0386", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", NIL, .F.)
      o := "A_0387|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0387", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", NIL, .T.)
      o := "A_0388|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0388", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", NIL, .T., .T.)
      o := "A_0389|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0389", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", NIL, .T., .F.)
      o := "A_0390|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0390", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P013()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", " ")
      o := "A_0391|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0391", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", " ", .F.)
      o := "A_0392|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0392", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", " ", .T.)
      o := "A_0393|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0393", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", " ", .T., .T.)
      o := "A_0394|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0394", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", " ", .T., .F.)
      o := "A_0395|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0395", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ",")
      o := "A_0396|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0396", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ",", .F.)
      o := "A_0397|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0397", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ",", .T.)
      o := "A_0398|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0398", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ",", .T., .T.)
      o := "A_0399|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0399", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ",", .T., .F.)
      o := "A_0400|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0400", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ", ")
      o := "A_0401|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0401", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ", ", .F.)
      o := "A_0402|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0402", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ", ", .T.)
      o := "A_0403|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0403", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ", ", .T., .T.)
      o := "A_0404|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0404", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ", ", .T., .F.)
      o := "A_0405|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0405", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ";")
      o := "A_0406|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0406", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ";", .F.)
      o := "A_0407|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0407", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ";", .T.)
      o := "A_0408|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0408", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ";", .T., .T.)
      o := "A_0409|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0409", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", ";", .T., .F.)
      o := "A_0410|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0410", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", "::")
      o := "A_0411|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0411", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", "::", .F.)
      o := "A_0412|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0412", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", "::", .T.)
      o := "A_0413|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0413", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", "::", .T., .T.)
      o := "A_0414|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0414", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", "::", .T., .F.)
      o := "A_0415|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0415", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", "")
      o := "A_0416|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0416", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", "", .F.)
      o := "A_0417|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0417", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", "", .T.)
      o := "A_0418|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0418", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", "", .T., .T.)
      o := "A_0419|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0419", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b;c", "", .T., .F.)
      o := "A_0420|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0420", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P014()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b")
      o := "A_0421|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0421", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", NIL, .F.)
      o := "A_0422|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0422", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", NIL, .T.)
      o := "A_0423|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0423", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", NIL, .T., .T.)
      o := "A_0424|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0424", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", NIL, .T., .F.)
      o := "A_0425|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0425", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", " ")
      o := "A_0426|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0426", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", " ", .F.)
      o := "A_0427|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0427", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", " ", .T.)
      o := "A_0428|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0428", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", " ", .T., .T.)
      o := "A_0429|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0429", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", " ", .T., .F.)
      o := "A_0430|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0430", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ",")
      o := "A_0431|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0431", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ",", .F.)
      o := "A_0432|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0432", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ",", .T.)
      o := "A_0433|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0433", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ",", .T., .T.)
      o := "A_0434|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0434", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ",", .T., .F.)
      o := "A_0435|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0435", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ", ")
      o := "A_0436|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0436", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ", ", .F.)
      o := "A_0437|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0437", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ", ", .T.)
      o := "A_0438|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0438", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ", ", .T., .T.)
      o := "A_0439|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0439", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ", ", .T., .F.)
      o := "A_0440|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0440", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ";")
      o := "A_0441|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0441", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ";", .F.)
      o := "A_0442|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0442", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ";", .T.)
      o := "A_0443|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0443", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ";", .T., .T.)
      o := "A_0444|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0444", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", ";", .T., .F.)
      o := "A_0445|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0445", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", "::")
      o := "A_0446|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0446", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", "::", .F.)
      o := "A_0447|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0447", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", "::", .T.)
      o := "A_0448|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0448", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", "::", .T., .T.)
      o := "A_0449|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0449", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", "::", .T., .F.)
      o := "A_0450|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0450", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P015()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", "")
      o := "A_0451|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0451", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", "", .F.)
      o := "A_0452|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0452", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", "", .T.)
      o := "A_0453|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0453", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", "", .T., .T.)
      o := "A_0454|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0454", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b", "", .T., .F.)
      o := "A_0455|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0455", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c")
      o := "A_0456|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0456", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", NIL, .F.)
      o := "A_0457|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0457", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", NIL, .T.)
      o := "A_0458|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0458", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", NIL, .T., .T.)
      o := "A_0459|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0459", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", NIL, .T., .F.)
      o := "A_0460|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0460", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", " ")
      o := "A_0461|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0461", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", " ", .F.)
      o := "A_0462|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0462", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", " ", .T.)
      o := "A_0463|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0463", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", " ", .T., .T.)
      o := "A_0464|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0464", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", " ", .T., .F.)
      o := "A_0465|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0465", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ",")
      o := "A_0466|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0466", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ",", .F.)
      o := "A_0467|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0467", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ",", .T.)
      o := "A_0468|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0468", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ",", .T., .T.)
      o := "A_0469|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0469", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ",", .T., .F.)
      o := "A_0470|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0470", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ", ")
      o := "A_0471|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0471", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ", ", .F.)
      o := "A_0472|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0472", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ", ", .T.)
      o := "A_0473|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0473", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ", ", .T., .T.)
      o := "A_0474|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0474", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ", ", .T., .F.)
      o := "A_0475|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0475", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ";")
      o := "A_0476|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0476", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ";", .F.)
      o := "A_0477|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0477", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ";", .T.)
      o := "A_0478|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0478", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ";", .T., .T.)
      o := "A_0479|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0479", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", ";", .T., .F.)
      o := "A_0480|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0480", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P016()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", "::")
      o := "A_0481|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0481", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", "::", .F.)
      o := "A_0482|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0482", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", "::", .T.)
      o := "A_0483|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0483", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", "::", .T., .T.)
      o := "A_0484|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0484", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", "::", .T., .F.)
      o := "A_0485|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0485", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", "")
      o := "A_0486|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0486", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", "", .F.)
      o := "A_0487|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0487", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", "", .T.)
      o := "A_0488|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0488", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", "", .T., .T.)
      o := "A_0489|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0489", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(13) + Chr(10) + "b" + Chr(10) + "c", "", .T., .F.)
      o := "A_0490|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0490", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four")
      o := "A_0491|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0491", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", NIL, .F.)
      o := "A_0492|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0492", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", NIL, .T.)
      o := "A_0493|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0493", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", NIL, .T., .T.)
      o := "A_0494|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0494", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", NIL, .T., .F.)
      o := "A_0495|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0495", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", " ")
      o := "A_0496|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0496", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", " ", .F.)
      o := "A_0497|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0497", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", " ", .T.)
      o := "A_0498|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0498", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", " ", .T., .T.)
      o := "A_0499|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0499", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", " ", .T., .F.)
      o := "A_0500|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0500", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ",")
      o := "A_0501|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0501", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ",", .F.)
      o := "A_0502|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0502", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ",", .T.)
      o := "A_0503|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0503", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ",", .T., .T.)
      o := "A_0504|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0504", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ",", .T., .F.)
      o := "A_0505|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0505", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ", ")
      o := "A_0506|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0506", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ", ", .F.)
      o := "A_0507|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0507", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ", ", .T.)
      o := "A_0508|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0508", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ", ", .T., .T.)
      o := "A_0509|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0509", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ", ", .T., .F.)
      o := "A_0510|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0510", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P017()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ";")
      o := "A_0511|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0511", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ";", .F.)
      o := "A_0512|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0512", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ";", .T.)
      o := "A_0513|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0513", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ";", .T., .T.)
      o := "A_0514|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0514", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", ";", .T., .F.)
      o := "A_0515|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0515", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", "::")
      o := "A_0516|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0516", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", "::", .F.)
      o := "A_0517|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0517", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", "::", .T.)
      o := "A_0518|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0518", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", "::", .T., .T.)
      o := "A_0519|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0519", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", "::", .T., .F.)
      o := "A_0520|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0520", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", "")
      o := "A_0521|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0521", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", "", .F.)
      o := "A_0522|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0522", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", "", .T.)
      o := "A_0523|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0523", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", "", .T., .T.)
      o := "A_0524|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0524", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four", "", .T., .F.)
      o := "A_0525|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0525", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b")
      o := "A_0526|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0526", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", NIL, .F.)
      o := "A_0527|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0527", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", NIL, .T.)
      o := "A_0528|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0528", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", NIL, .T., .T.)
      o := "A_0529|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0529", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", NIL, .T., .F.)
      o := "A_0530|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0530", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", " ")
      o := "A_0531|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0531", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", " ", .F.)
      o := "A_0532|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0532", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", " ", .T.)
      o := "A_0533|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0533", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", " ", .T., .T.)
      o := "A_0534|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0534", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", " ", .T., .F.)
      o := "A_0535|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0535", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ",")
      o := "A_0536|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0536", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ",", .F.)
      o := "A_0537|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0537", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ",", .T.)
      o := "A_0538|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0538", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ",", .T., .T.)
      o := "A_0539|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0539", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ",", .T., .F.)
      o := "A_0540|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0540", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P018()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ", ")
      o := "A_0541|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0541", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ", ", .F.)
      o := "A_0542|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0542", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ", ", .T.)
      o := "A_0543|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0543", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ", ", .T., .T.)
      o := "A_0544|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0544", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ", ", .T., .F.)
      o := "A_0545|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0545", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ";")
      o := "A_0546|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0546", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ";", .F.)
      o := "A_0547|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0547", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ";", .T.)
      o := "A_0548|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0548", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ";", .T., .T.)
      o := "A_0549|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0549", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", ";", .T., .F.)
      o := "A_0550|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0550", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", "::")
      o := "A_0551|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0551", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", "::", .F.)
      o := "A_0552|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0552", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", "::", .T.)
      o := "A_0553|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0553", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", "::", .T., .T.)
      o := "A_0554|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0554", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", "::", .T., .F.)
      o := "A_0555|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0555", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", "")
      o := "A_0556|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0556", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", "", .F.)
      o := "A_0557|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0557", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", "", .T.)
      o := "A_0558|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0558", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", "", .T., .T.)
      o := "A_0559|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0559", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a;;b", "", .T., .F.)
      o := "A_0560|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0560", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z")
      o := "A_0561|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0561", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", NIL, .F.)
      o := "A_0562|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0562", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", NIL, .T.)
      o := "A_0563|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0563", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", NIL, .T., .T.)
      o := "A_0564|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0564", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", NIL, .T., .F.)
      o := "A_0565|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0565", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", " ")
      o := "A_0566|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0566", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", " ", .F.)
      o := "A_0567|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0567", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", " ", .T.)
      o := "A_0568|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0568", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", " ", .T., .T.)
      o := "A_0569|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0569", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", " ", .T., .F.)
      o := "A_0570|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0570", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P019()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ",")
      o := "A_0571|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0571", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ",", .F.)
      o := "A_0572|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0572", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ",", .T.)
      o := "A_0573|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0573", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ",", .T., .T.)
      o := "A_0574|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0574", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ",", .T., .F.)
      o := "A_0575|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0575", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ", ")
      o := "A_0576|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0576", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ", ", .F.)
      o := "A_0577|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0577", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ", ", .T.)
      o := "A_0578|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0578", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ", ", .T., .T.)
      o := "A_0579|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0579", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ", ", .T., .F.)
      o := "A_0580|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0580", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ";")
      o := "A_0581|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0581", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ";", .F.)
      o := "A_0582|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0582", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ";", .T.)
      o := "A_0583|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0583", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ";", .T., .T.)
      o := "A_0584|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0584", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", ";", .T., .F.)
      o := "A_0585|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0585", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", "::")
      o := "A_0586|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0586", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", "::", .F.)
      o := "A_0587|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0587", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", "::", .T.)
      o := "A_0588|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0588", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", "::", .T., .T.)
      o := "A_0589|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0589", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", "::", .T., .F.)
      o := "A_0590|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0590", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", "")
      o := "A_0591|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0591", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", "", .F.)
      o := "A_0592|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0592", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", "", .T.)
      o := "A_0593|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0593", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", "", .T., .T.)
      o := "A_0594|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0594", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z", "", .T., .F.)
      o := "A_0595|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0595", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now")
      o := "A_0596|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0596", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", NIL, .F.)
      o := "A_0597|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0597", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", NIL, .T.)
      o := "A_0598|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0598", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", NIL, .T., .T.)
      o := "A_0599|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0599", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", NIL, .T., .F.)
      o := "A_0600|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0600", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P020()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", " ")
      o := "A_0601|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0601", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", " ", .F.)
      o := "A_0602|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0602", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", " ", .T.)
      o := "A_0603|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0603", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", " ", .T., .T.)
      o := "A_0604|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0604", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", " ", .T., .F.)
      o := "A_0605|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0605", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ",")
      o := "A_0606|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0606", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ",", .F.)
      o := "A_0607|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0607", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ",", .T.)
      o := "A_0608|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0608", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ",", .T., .T.)
      o := "A_0609|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0609", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ",", .T., .F.)
      o := "A_0610|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0610", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ", ")
      o := "A_0611|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0611", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ", ", .F.)
      o := "A_0612|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0612", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ", ", .T.)
      o := "A_0613|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0613", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ", ", .T., .T.)
      o := "A_0614|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0614", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ", ", .T., .F.)
      o := "A_0615|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0615", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ";")
      o := "A_0616|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0616", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ";", .F.)
      o := "A_0617|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0617", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ";", .T.)
      o := "A_0618|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0618", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ";", .T., .T.)
      o := "A_0619|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0619", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", ";", .T., .F.)
      o := "A_0620|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0620", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", "::")
      o := "A_0621|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0621", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", "::", .F.)
      o := "A_0622|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0622", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", "::", .T.)
      o := "A_0623|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0623", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", "::", .T., .T.)
      o := "A_0624|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0624", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", "::", .T., .F.)
      o := "A_0625|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0625", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", "")
      o := "A_0626|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0626", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", "", .F.)
      o := "A_0627|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0627", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", "", .T.)
      o := "A_0628|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0628", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", "", .T., .T.)
      o := "A_0629|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0629", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say " + Chr(34) + "hello world" + Chr(34) + " now", "", .T., .F.)
      o := "A_0630|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0630", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P021()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now")
      o := "A_0631|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0631", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", NIL, .F.)
      o := "A_0632|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0632", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", NIL, .T.)
      o := "A_0633|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0633", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", NIL, .T., .T.)
      o := "A_0634|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0634", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", NIL, .T., .F.)
      o := "A_0635|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0635", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", " ")
      o := "A_0636|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0636", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", " ", .F.)
      o := "A_0637|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0637", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", " ", .T.)
      o := "A_0638|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0638", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", " ", .T., .T.)
      o := "A_0639|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0639", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", " ", .T., .F.)
      o := "A_0640|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0640", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ",")
      o := "A_0641|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0641", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ",", .F.)
      o := "A_0642|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0642", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ",", .T.)
      o := "A_0643|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0643", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ",", .T., .T.)
      o := "A_0644|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0644", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ",", .T., .F.)
      o := "A_0645|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0645", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ", ")
      o := "A_0646|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0646", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ", ", .F.)
      o := "A_0647|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0647", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ", ", .T.)
      o := "A_0648|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0648", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ", ", .T., .T.)
      o := "A_0649|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0649", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ", ", .T., .F.)
      o := "A_0650|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0650", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ";")
      o := "A_0651|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0651", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ";", .F.)
      o := "A_0652|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0652", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ";", .T.)
      o := "A_0653|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0653", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ";", .T., .T.)
      o := "A_0654|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0654", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", ";", .T., .F.)
      o := "A_0655|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0655", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", "::")
      o := "A_0656|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0656", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", "::", .F.)
      o := "A_0657|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0657", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", "::", .T.)
      o := "A_0658|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0658", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", "::", .T., .T.)
      o := "A_0659|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0659", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", "::", .T., .F.)
      o := "A_0660|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0660", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P022()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", "")
      o := "A_0661|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0661", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", "", .F.)
      o := "A_0662|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0662", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", "", .T.)
      o := "A_0663|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0663", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", "", .T., .T.)
      o := "A_0664|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0664", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("say 'hi there' now", "", .T., .F.)
      o := "A_0665|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0665", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d")
      o := "A_0666|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0666", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", NIL, .F.)
      o := "A_0667|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0667", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", NIL, .T.)
      o := "A_0668|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0668", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", NIL, .T., .T.)
      o := "A_0669|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0669", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", NIL, .T., .F.)
      o := "A_0670|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0670", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", " ")
      o := "A_0671|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0671", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", " ", .F.)
      o := "A_0672|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0672", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", " ", .T.)
      o := "A_0673|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0673", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", " ", .T., .T.)
      o := "A_0674|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0674", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", " ", .T., .F.)
      o := "A_0675|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0675", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ",")
      o := "A_0676|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0676", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ",", .F.)
      o := "A_0677|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0677", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ",", .T.)
      o := "A_0678|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0678", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ",", .T., .T.)
      o := "A_0679|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0679", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ",", .T., .F.)
      o := "A_0680|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0680", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ", ")
      o := "A_0681|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0681", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ", ", .F.)
      o := "A_0682|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0682", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ", ", .T.)
      o := "A_0683|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0683", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ", ", .T., .T.)
      o := "A_0684|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0684", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ", ", .T., .F.)
      o := "A_0685|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0685", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ";")
      o := "A_0686|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0686", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ";", .F.)
      o := "A_0687|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0687", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ";", .T.)
      o := "A_0688|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0688", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ";", .T., .T.)
      o := "A_0689|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0689", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", ";", .T., .F.)
      o := "A_0690|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0690", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P023()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", "::")
      o := "A_0691|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0691", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", "::", .F.)
      o := "A_0692|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0692", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", "::", .T.)
      o := "A_0693|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0693", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", "::", .T., .T.)
      o := "A_0694|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0694", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", "::", .T., .F.)
      o := "A_0695|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0695", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", "")
      o := "A_0696|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0696", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", "", .F.)
      o := "A_0697|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0697", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", "", .T.)
      o := "A_0698|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0698", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", "", .T., .T.)
      o := "A_0699|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0699", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(34) + "b c" + Chr(34) + "d", "", .T., .F.)
      o := "A_0700|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0700", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here")
      o := "A_0701|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0701", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", NIL, .F.)
      o := "A_0702|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0702", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", NIL, .T.)
      o := "A_0703|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0703", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", NIL, .T., .T.)
      o := "A_0704|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0704", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", NIL, .T., .F.)
      o := "A_0705|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0705", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", " ")
      o := "A_0706|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0706", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", " ", .F.)
      o := "A_0707|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0707", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", " ", .T.)
      o := "A_0708|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0708", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", " ", .T., .T.)
      o := "A_0709|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0709", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", " ", .T., .F.)
      o := "A_0710|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0710", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ",")
      o := "A_0711|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0711", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ",", .F.)
      o := "A_0712|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0712", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ",", .T.)
      o := "A_0713|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0713", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ",", .T., .T.)
      o := "A_0714|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0714", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ",", .T., .F.)
      o := "A_0715|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0715", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ", ")
      o := "A_0716|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0716", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ", ", .F.)
      o := "A_0717|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0717", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ", ", .T.)
      o := "A_0718|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0718", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ", ", .T., .T.)
      o := "A_0719|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0719", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ", ", .T., .F.)
      o := "A_0720|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0720", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P024()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ";")
      o := "A_0721|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0721", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ";", .F.)
      o := "A_0722|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0722", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ";", .T.)
      o := "A_0723|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0723", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ";", .T., .T.)
      o := "A_0724|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0724", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", ";", .T., .F.)
      o := "A_0725|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0725", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", "::")
      o := "A_0726|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0726", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", "::", .F.)
      o := "A_0727|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0727", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", "::", .T.)
      o := "A_0728|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0728", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", "::", .T., .T.)
      o := "A_0729|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0729", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", "::", .T., .F.)
      o := "A_0730|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0730", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", "")
      o := "A_0731|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0731", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", "", .F.)
      o := "A_0732|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0732", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", "", .T.)
      o := "A_0733|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0733", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", "", .T., .T.)
      o := "A_0734|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0734", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("unterminated " + Chr(34) + "quote here", "", .T., .F.)
      o := "A_0735|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0735", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok")
      o := "A_0736|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0736", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", NIL, .F.)
      o := "A_0737|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0737", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", NIL, .T.)
      o := "A_0738|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0738", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", NIL, .T., .T.)
      o := "A_0739|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0739", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", NIL, .T., .F.)
      o := "A_0740|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0740", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", " ")
      o := "A_0741|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0741", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", " ", .F.)
      o := "A_0742|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0742", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", " ", .T.)
      o := "A_0743|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0743", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", " ", .T., .T.)
      o := "A_0744|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0744", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", " ", .T., .F.)
      o := "A_0745|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0745", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ",")
      o := "A_0746|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0746", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ",", .F.)
      o := "A_0747|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0747", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ",", .T.)
      o := "A_0748|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0748", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ",", .T., .T.)
      o := "A_0749|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0749", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ",", .T., .F.)
      o := "A_0750|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0750", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P025()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ", ")
      o := "A_0751|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0751", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ", ", .F.)
      o := "A_0752|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0752", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ", ", .T.)
      o := "A_0753|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0753", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ", ", .T., .T.)
      o := "A_0754|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0754", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ", ", .T., .F.)
      o := "A_0755|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0755", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ";")
      o := "A_0756|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0756", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ";", .F.)
      o := "A_0757|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0757", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ";", .T.)
      o := "A_0758|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0758", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ";", .T., .T.)
      o := "A_0759|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0759", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", ";", .T., .F.)
      o := "A_0760|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0760", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", "::")
      o := "A_0761|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0761", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", "::", .F.)
      o := "A_0762|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0762", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", "::", .T.)
      o := "A_0763|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0763", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", "::", .T., .T.)
      o := "A_0764|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0764", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", "::", .T., .F.)
      o := "A_0765|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0765", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", "")
      o := "A_0766|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0766", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", "", .F.)
      o := "A_0767|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0767", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", "", .T.)
      o := "A_0768|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0768", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", "", .T., .T.)
      o := "A_0769|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0769", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("it's a 'test' ok", "", .T., .F.)
      o := "A_0770|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0770", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e")
      o := "A_0771|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0771", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", NIL, .F.)
      o := "A_0772|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0772", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", NIL, .T.)
      o := "A_0773|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0773", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", NIL, .T., .T.)
      o := "A_0774|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0774", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", NIL, .T., .F.)
      o := "A_0775|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0775", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", " ")
      o := "A_0776|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0776", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", " ", .F.)
      o := "A_0777|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0777", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", " ", .T.)
      o := "A_0778|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0778", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", " ", .T., .T.)
      o := "A_0779|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0779", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", " ", .T., .F.)
      o := "A_0780|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0780", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P026()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ",")
      o := "A_0781|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0781", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ",", .F.)
      o := "A_0782|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0782", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ",", .T.)
      o := "A_0783|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0783", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ",", .T., .T.)
      o := "A_0784|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0784", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ",", .T., .F.)
      o := "A_0785|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0785", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ", ")
      o := "A_0786|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0786", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ", ", .F.)
      o := "A_0787|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0787", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ", ", .T.)
      o := "A_0788|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0788", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ", ", .T., .T.)
      o := "A_0789|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0789", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ", ", .T., .F.)
      o := "A_0790|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0790", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ";")
      o := "A_0791|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0791", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ";", .F.)
      o := "A_0792|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0792", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ";", .T.)
      o := "A_0793|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0793", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ";", .T., .T.)
      o := "A_0794|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0794", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", ";", .T., .F.)
      o := "A_0795|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0795", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", "::")
      o := "A_0796|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0796", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", "::", .F.)
      o := "A_0797|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0797", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", "::", .T.)
      o := "A_0798|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0798", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", "::", .T., .T.)
      o := "A_0799|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0799", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", "::", .T., .F.)
      o := "A_0800|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0800", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", "")
      o := "A_0801|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0801", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", "", .F.)
      o := "A_0802|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0802", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", "", .T.)
      o := "A_0803|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0803", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", "", .T., .T.)
      o := "A_0804|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0804", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b" + Chr(34) + " " + Chr(34) + "c d" + Chr(34) + " e", "", .T., .F.)
      o := "A_0805|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0805", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34))
      o := "A_0806|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0806", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), NIL, .F.)
      o := "A_0807|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0807", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), NIL, .T.)
      o := "A_0808|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0808", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), NIL, .T., .T.)
      o := "A_0809|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0809", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), NIL, .T., .F.)
      o := "A_0810|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0810", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P027()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), " ")
      o := "A_0811|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0811", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), " ", .F.)
      o := "A_0812|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0812", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), " ", .T.)
      o := "A_0813|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0813", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), " ", .T., .T.)
      o := "A_0814|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0814", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), " ", .T., .F.)
      o := "A_0815|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0815", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ",")
      o := "A_0816|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0816", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ",", .F.)
      o := "A_0817|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0817", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ",", .T.)
      o := "A_0818|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0818", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ",", .T., .T.)
      o := "A_0819|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0819", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ",", .T., .F.)
      o := "A_0820|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0820", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ", ")
      o := "A_0821|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0821", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ", ", .F.)
      o := "A_0822|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0822", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ", ", .T.)
      o := "A_0823|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0823", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ", ", .T., .T.)
      o := "A_0824|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0824", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ", ", .T., .F.)
      o := "A_0825|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0825", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ";")
      o := "A_0826|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0826", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ";", .F.)
      o := "A_0827|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0827", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ";", .T.)
      o := "A_0828|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0828", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ";", .T., .T.)
      o := "A_0829|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0829", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), ";", .T., .F.)
      o := "A_0830|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0830", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), "::")
      o := "A_0831|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0831", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), "::", .F.)
      o := "A_0832|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0832", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), "::", .T.)
      o := "A_0833|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0833", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), "::", .T., .T.)
      o := "A_0834|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0834", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), "::", .T., .F.)
      o := "A_0835|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0835", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), "")
      o := "A_0836|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0836", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), "", .F.)
      o := "A_0837|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0837", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), "", .T.)
      o := "A_0838|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0838", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), "", .T., .T.)
      o := "A_0839|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0839", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "only" + Chr(34), "", .T., .F.)
      o := "A_0840|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0840", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P028()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34))
      o := "A_0841|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0841", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), NIL, .F.)
      o := "A_0842|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0842", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), NIL, .T.)
      o := "A_0843|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0843", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), NIL, .T., .T.)
      o := "A_0844|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0844", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), NIL, .T., .F.)
      o := "A_0845|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0845", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), " ")
      o := "A_0846|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0846", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), " ", .F.)
      o := "A_0847|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0847", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), " ", .T.)
      o := "A_0848|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0848", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), " ", .T., .T.)
      o := "A_0849|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0849", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), " ", .T., .F.)
      o := "A_0850|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0850", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ",")
      o := "A_0851|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0851", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ",", .F.)
      o := "A_0852|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0852", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ",", .T.)
      o := "A_0853|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0853", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ",", .T., .T.)
      o := "A_0854|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0854", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ",", .T., .F.)
      o := "A_0855|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0855", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ", ")
      o := "A_0856|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0856", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ", ", .F.)
      o := "A_0857|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0857", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ", ", .T.)
      o := "A_0858|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0858", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ", ", .T., .T.)
      o := "A_0859|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0859", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ", ", .T., .F.)
      o := "A_0860|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0860", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ";")
      o := "A_0861|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0861", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ";", .F.)
      o := "A_0862|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0862", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ";", .T.)
      o := "A_0863|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0863", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ";", .T., .T.)
      o := "A_0864|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0864", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), ";", .T., .F.)
      o := "A_0865|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0865", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), "::")
      o := "A_0866|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0866", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), "::", .F.)
      o := "A_0867|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0867", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), "::", .T.)
      o := "A_0868|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0868", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), "::", .T., .T.)
      o := "A_0869|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0869", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), "::", .T., .F.)
      o := "A_0870|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0870", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P029()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), "")
      o := "A_0871|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0871", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), "", .F.)
      o := "A_0872|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0872", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), "", .T.)
      o := "A_0873|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0873", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), "", .T., .T.)
      o := "A_0874|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0874", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + Chr(34), "", .T., .F.)
      o := "A_0875|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0875", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34))
      o := "A_0876|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0876", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), NIL, .F.)
      o := "A_0877|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0877", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), NIL, .T.)
      o := "A_0878|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0878", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), NIL, .T., .T.)
      o := "A_0879|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0879", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), NIL, .T., .F.)
      o := "A_0880|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0880", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), " ")
      o := "A_0881|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0881", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), " ", .F.)
      o := "A_0882|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0882", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), " ", .T.)
      o := "A_0883|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0883", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), " ", .T., .T.)
      o := "A_0884|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0884", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), " ", .T., .F.)
      o := "A_0885|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0885", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ",")
      o := "A_0886|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0886", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ",", .F.)
      o := "A_0887|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0887", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ",", .T.)
      o := "A_0888|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0888", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ",", .T., .T.)
      o := "A_0889|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0889", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ",", .T., .F.)
      o := "A_0890|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0890", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ", ")
      o := "A_0891|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0891", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ", ", .F.)
      o := "A_0892|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0892", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ", ", .T.)
      o := "A_0893|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0893", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ", ", .T., .T.)
      o := "A_0894|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0894", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ", ", .T., .F.)
      o := "A_0895|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0895", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ";")
      o := "A_0896|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0896", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ";", .F.)
      o := "A_0897|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0897", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ";", .T.)
      o := "A_0898|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0898", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ";", .T., .T.)
      o := "A_0899|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0899", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), ";", .T., .F.)
      o := "A_0900|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0900", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P030()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), "::")
      o := "A_0901|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0901", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), "::", .F.)
      o := "A_0902|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0902", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), "::", .T.)
      o := "A_0903|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0903", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), "::", .T., .T.)
      o := "A_0904|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0904", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), "::", .T., .F.)
      o := "A_0905|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0905", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), "")
      o := "A_0906|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0906", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), "", .F.)
      o := "A_0907|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0907", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), "", .T.)
      o := "A_0908|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0908", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), "", .T., .T.)
      o := "A_0909|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0909", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "a" + Chr(34) + Chr(34) + "b" + Chr(34), "", .T., .F.)
      o := "A_0910|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0910", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e")
      o := "A_0911|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0911", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", NIL, .F.)
      o := "A_0912|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0912", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", NIL, .T.)
      o := "A_0913|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0913", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", NIL, .T., .T.)
      o := "A_0914|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0914", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", NIL, .T., .F.)
      o := "A_0915|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0915", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", " ")
      o := "A_0916|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0916", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", " ", .F.)
      o := "A_0917|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0917", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", " ", .T.)
      o := "A_0918|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0918", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", " ", .T., .T.)
      o := "A_0919|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0919", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", " ", .T., .F.)
      o := "A_0920|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0920", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ",")
      o := "A_0921|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0921", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ",", .F.)
      o := "A_0922|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0922", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ",", .T.)
      o := "A_0923|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0923", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ",", .T., .T.)
      o := "A_0924|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0924", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ",", .T., .F.)
      o := "A_0925|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0925", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ", ")
      o := "A_0926|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0926", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ", ", .F.)
      o := "A_0927|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0927", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ", ", .T.)
      o := "A_0928|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0928", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ", ", .T., .T.)
      o := "A_0929|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0929", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ", ", .T., .F.)
      o := "A_0930|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0930", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P031()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ";")
      o := "A_0931|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0931", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ";", .F.)
      o := "A_0932|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0932", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ";", .T.)
      o := "A_0933|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0933", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ";", .T., .T.)
      o := "A_0934|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0934", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", ";", .T., .F.)
      o := "A_0935|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0935", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", "::")
      o := "A_0936|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0936", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", "::", .F.)
      o := "A_0937|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0937", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", "::", .T.)
      o := "A_0938|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0938", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", "::", .T., .T.)
      o := "A_0939|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0939", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", "::", .T., .F.)
      o := "A_0940|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0940", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", "")
      o := "A_0941|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0941", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", "", .F.)
      o := "A_0942|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0942", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", "", .T.)
      o := "A_0943|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0943", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", "", .T., .T.)
      o := "A_0944|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0944", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b,c" + Chr(34) + " d,e", "", .T., .F.)
      o := "A_0945|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0945", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d")
      o := "A_0946|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0946", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", NIL, .F.)
      o := "A_0947|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0947", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", NIL, .T.)
      o := "A_0948|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0948", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", NIL, .T., .T.)
      o := "A_0949|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0949", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", NIL, .T., .F.)
      o := "A_0950|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0950", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", " ")
      o := "A_0951|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0951", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", " ", .F.)
      o := "A_0952|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0952", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", " ", .T.)
      o := "A_0953|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0953", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", " ", .T., .T.)
      o := "A_0954|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0954", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", " ", .T., .F.)
      o := "A_0955|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0955", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ",")
      o := "A_0956|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0956", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ",", .F.)
      o := "A_0957|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0957", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ",", .T.)
      o := "A_0958|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0958", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ",", .T., .T.)
      o := "A_0959|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0959", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ",", .T., .F.)
      o := "A_0960|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0960", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P032()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ", ")
      o := "A_0961|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0961", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ", ", .F.)
      o := "A_0962|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0962", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ", ", .T.)
      o := "A_0963|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0963", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ", ", .T., .T.)
      o := "A_0964|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0964", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ", ", .T., .F.)
      o := "A_0965|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0965", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ";")
      o := "A_0966|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0966", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ";", .F.)
      o := "A_0967|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0967", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ";", .T.)
      o := "A_0968|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0968", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ";", .T., .T.)
      o := "A_0969|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0969", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", ";", .T., .F.)
      o := "A_0970|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0970", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", "::")
      o := "A_0971|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0971", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", "::", .F.)
      o := "A_0972|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0972", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", "::", .T.)
      o := "A_0973|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0973", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", "::", .T., .T.)
      o := "A_0974|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0974", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", "::", .T., .F.)
      o := "A_0975|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0975", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", "")
      o := "A_0976|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0976", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", "", .F.)
      o := "A_0977|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0977", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", "", .T.)
      o := "A_0978|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0978", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", "", .T., .T.)
      o := "A_0979|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0979", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a`b c`d", "", .T., .F.)
      o := "A_0980|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0980", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d")
      o := "A_0981|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0981", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", NIL, .F.)
      o := "A_0982|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0982", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", NIL, .T.)
      o := "A_0983|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0983", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", NIL, .T., .T.)
      o := "A_0984|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0984", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", NIL, .T., .F.)
      o := "A_0985|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0985", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", " ")
      o := "A_0986|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0986", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", " ", .F.)
      o := "A_0987|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0987", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", " ", .T.)
      o := "A_0988|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0988", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", " ", .T., .T.)
      o := "A_0989|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0989", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", " ", .T., .F.)
      o := "A_0990|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0990", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P033()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ",")
      o := "A_0991|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0991", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ",", .F.)
      o := "A_0992|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0992", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ",", .T.)
      o := "A_0993|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0993", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ",", .T., .T.)
      o := "A_0994|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0994", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ",", .T., .F.)
      o := "A_0995|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0995", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ", ")
      o := "A_0996|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0996", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ", ", .F.)
      o := "A_0997|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0997", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ", ", .T.)
      o := "A_0998|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0998", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ", ", .T., .T.)
      o := "A_0999|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_0999", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ", ", .T., .F.)
      o := "A_1000|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1000", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ";")
      o := "A_1001|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1001", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ";", .F.)
      o := "A_1002|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1002", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ";", .T.)
      o := "A_1003|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1003", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ";", .T., .T.)
      o := "A_1004|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1004", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", ";", .T., .F.)
      o := "A_1005|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1005", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", "::")
      o := "A_1006|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1006", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", "::", .F.)
      o := "A_1007|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1007", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", "::", .T.)
      o := "A_1008|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1008", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", "::", .T., .T.)
      o := "A_1009|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1009", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", "::", .T., .F.)
      o := "A_1010|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1010", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", "")
      o := "A_1011|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1011", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", "", .F.)
      o := "A_1012|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1012", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", "", .T.)
      o := "A_1013|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1013", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", "", .T., .T.)
      o := "A_1014|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1014", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a[b c]d", "", .T., .F.)
      o := "A_1015|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1015", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end")
      o := "A_1016|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1016", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", NIL, .F.)
      o := "A_1017|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1017", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", NIL, .T.)
      o := "A_1018|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1018", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", NIL, .T., .T.)
      o := "A_1019|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1019", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", NIL, .T., .F.)
      o := "A_1020|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1020", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P034()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", " ")
      o := "A_1021|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1021", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", " ", .F.)
      o := "A_1022|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1022", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", " ", .T.)
      o := "A_1023|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1023", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", " ", .T., .T.)
      o := "A_1024|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1024", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", " ", .T., .F.)
      o := "A_1025|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1025", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ",")
      o := "A_1026|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1026", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ",", .F.)
      o := "A_1027|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1027", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ",", .T.)
      o := "A_1028|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1028", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ",", .T., .T.)
      o := "A_1029|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1029", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ",", .T., .F.)
      o := "A_1030|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1030", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ", ")
      o := "A_1031|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1031", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ", ", .F.)
      o := "A_1032|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1032", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ", ", .T.)
      o := "A_1033|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1033", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ", ", .T., .T.)
      o := "A_1034|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1034", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ", ", .T., .F.)
      o := "A_1035|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1035", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ";")
      o := "A_1036|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1036", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ";", .F.)
      o := "A_1037|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1037", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ";", .T.)
      o := "A_1038|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1038", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ";", .T., .T.)
      o := "A_1039|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1039", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", ";", .T., .F.)
      o := "A_1040|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1040", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", "::")
      o := "A_1041|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1041", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", "::", .F.)
      o := "A_1042|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1042", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", "::", .T.)
      o := "A_1043|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1043", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", "::", .T., .T.)
      o := "A_1044|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1044", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", "::", .T., .F.)
      o := "A_1045|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1045", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", "")
      o := "A_1046|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1046", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", "", .F.)
      o := "A_1047|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1047", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", "", .T.)
      o := "A_1048|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1048", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", "", .T., .T.)
      o := "A_1049|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1049", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("mix " + Chr(34) + "a b" + Chr(34) + " and 'c d' end", "", .T., .F.)
      o := "A_1050|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1050", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P035()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188))
      o := "A_1051|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1051", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), NIL, .F.)
      o := "A_1052|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1052", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), NIL, .T.)
      o := "A_1053|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1053", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), NIL, .T., .T.)
      o := "A_1054|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1054", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), NIL, .T., .F.)
      o := "A_1055|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1055", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), " ")
      o := "A_1056|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1056", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), " ", .F.)
      o := "A_1057|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1057", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), " ", .T.)
      o := "A_1058|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1058", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), " ", .T., .T.)
      o := "A_1059|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1059", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), " ", .T., .F.)
      o := "A_1060|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1060", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ",")
      o := "A_1061|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1061", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ",", .F.)
      o := "A_1062|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1062", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ",", .T.)
      o := "A_1063|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1063", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ",", .T., .T.)
      o := "A_1064|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1064", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ",", .T., .F.)
      o := "A_1065|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1065", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ", ")
      o := "A_1066|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1066", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ", ", .F.)
      o := "A_1067|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1067", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ", ", .T.)
      o := "A_1068|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1068", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ", ", .T., .T.)
      o := "A_1069|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1069", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ", ", .T., .F.)
      o := "A_1070|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1070", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ";")
      o := "A_1071|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1071", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ";", .F.)
      o := "A_1072|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1072", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ";", .T.)
      o := "A_1073|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1073", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ";", .T., .T.)
      o := "A_1074|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1074", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), ";", .T., .F.)
      o := "A_1075|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1075", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), "::")
      o := "A_1076|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1076", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), "::", .F.)
      o := "A_1077|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1077", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), "::", .T.)
      o := "A_1078|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1078", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), "::", .T., .T.)
      o := "A_1079|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1079", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), "::", .T., .F.)
      o := "A_1080|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1080", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P036()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), "")
      o := "A_1081|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1081", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), "", .F.)
      o := "A_1082|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1082", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), "", .T.)
      o := "A_1083|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1083", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), "", .T., .T.)
      o := "A_1084|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1084", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(195) + Chr(161) + Chr(195) + Chr(169) + " " + Chr(195) + Chr(177) + " " + Chr(195) + Chr(188), "", .T., .F.)
      o := "A_1085|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1085", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d")
      o := "A_1086|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1086", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", NIL, .F.)
      o := "A_1087|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1087", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", NIL, .T.)
      o := "A_1088|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1088", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", NIL, .T., .T.)
      o := "A_1089|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1089", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", NIL, .T., .F.)
      o := "A_1090|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1090", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", " ")
      o := "A_1091|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1091", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", " ", .F.)
      o := "A_1092|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1092", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", " ", .T.)
      o := "A_1093|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1093", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", " ", .T., .T.)
      o := "A_1094|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1094", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", " ", .T., .F.)
      o := "A_1095|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1095", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ",")
      o := "A_1096|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1096", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ",", .F.)
      o := "A_1097|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1097", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ",", .T.)
      o := "A_1098|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1098", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ",", .T., .T.)
      o := "A_1099|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1099", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ",", .T., .F.)
      o := "A_1100|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1100", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ", ")
      o := "A_1101|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1101", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ", ", .F.)
      o := "A_1102|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1102", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ", ", .T.)
      o := "A_1103|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1103", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ", ", .T., .T.)
      o := "A_1104|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1104", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ", ", .T., .F.)
      o := "A_1105|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1105", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ";")
      o := "A_1106|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1106", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ";", .F.)
      o := "A_1107|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1107", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ";", .T.)
      o := "A_1108|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1108", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ";", .T., .T.)
      o := "A_1109|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1109", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", ";", .T., .F.)
      o := "A_1110|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1110", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P037()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", "::")
      o := "A_1111|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1111", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", "::", .F.)
      o := "A_1112|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1112", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", "::", .T.)
      o := "A_1113|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1113", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", "::", .T., .T.)
      o := "A_1114|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1114", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", "::", .T., .F.)
      o := "A_1115|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1115", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", "")
      o := "A_1116|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1116", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", "", .F.)
      o := "A_1117|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1117", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", "", .T.)
      o := "A_1118|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1118", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", "", .T., .T.)
      o := "A_1119|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1119", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a-b_c.d", "", .T., .F.)
      o := "A_1120|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1120", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3")
      o := "A_1121|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1121", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", NIL, .F.)
      o := "A_1122|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1122", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", NIL, .T.)
      o := "A_1123|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1123", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", NIL, .T., .T.)
      o := "A_1124|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1124", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", NIL, .T., .F.)
      o := "A_1125|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1125", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", " ")
      o := "A_1126|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1126", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", " ", .F.)
      o := "A_1127|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1127", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", " ", .T.)
      o := "A_1128|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1128", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", " ", .T., .T.)
      o := "A_1129|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1129", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", " ", .T., .F.)
      o := "A_1130|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1130", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ",")
      o := "A_1131|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1131", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ",", .F.)
      o := "A_1132|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1132", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ",", .T.)
      o := "A_1133|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1133", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ",", .T., .T.)
      o := "A_1134|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1134", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ",", .T., .F.)
      o := "A_1135|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1135", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ", ")
      o := "A_1136|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1136", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ", ", .F.)
      o := "A_1137|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1137", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ", ", .T.)
      o := "A_1138|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1138", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ", ", .T., .T.)
      o := "A_1139|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1139", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ", ", .T., .F.)
      o := "A_1140|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1140", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P038()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ";")
      o := "A_1141|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1141", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ";", .F.)
      o := "A_1142|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1142", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ";", .T.)
      o := "A_1143|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1143", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ";", .T., .T.)
      o := "A_1144|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1144", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", ";", .T., .F.)
      o := "A_1145|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1145", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", "::")
      o := "A_1146|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1146", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", "::", .F.)
      o := "A_1147|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1147", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", "::", .T.)
      o := "A_1148|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1148", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", "::", .T., .T.)
      o := "A_1149|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1149", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", "::", .T., .F.)
      o := "A_1150|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1150", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", "")
      o := "A_1151|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1151", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", "", .F.)
      o := "A_1152|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1152", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", "", .T.)
      o := "A_1153|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1153", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", "", .T., .T.)
      o := "A_1154|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1154", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("1,2,3", "", .T., .F.)
      o := "A_1155|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1155", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c")
      o := "A_1156|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1156", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", NIL, .F.)
      o := "A_1157|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1157", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", NIL, .T.)
      o := "A_1158|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1158", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", NIL, .T., .T.)
      o := "A_1159|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1159", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", NIL, .T., .F.)
      o := "A_1160|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1160", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", " ")
      o := "A_1161|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1161", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", " ", .F.)
      o := "A_1162|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1162", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", " ", .T.)
      o := "A_1163|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1163", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", " ", .T., .T.)
      o := "A_1164|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1164", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", " ", .T., .F.)
      o := "A_1165|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1165", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ",")
      o := "A_1166|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1166", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ",", .F.)
      o := "A_1167|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1167", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ",", .T.)
      o := "A_1168|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1168", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ",", .T., .T.)
      o := "A_1169|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1169", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ",", .T., .F.)
      o := "A_1170|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1170", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P039()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ", ")
      o := "A_1171|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1171", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ", ", .F.)
      o := "A_1172|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1172", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ", ", .T.)
      o := "A_1173|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1173", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ", ", .T., .T.)
      o := "A_1174|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1174", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ", ", .T., .F.)
      o := "A_1175|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1175", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ";")
      o := "A_1176|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1176", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ";", .F.)
      o := "A_1177|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1177", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ";", .T.)
      o := "A_1178|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1178", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ";", .T., .T.)
      o := "A_1179|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1179", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", ";", .T., .F.)
      o := "A_1180|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1180", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", "::")
      o := "A_1181|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1181", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", "::", .F.)
      o := "A_1182|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1182", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", "::", .T.)
      o := "A_1183|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1183", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", "::", .T., .T.)
      o := "A_1184|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1184", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", "::", .T., .F.)
      o := "A_1185|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1185", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", "")
      o := "A_1186|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1186", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", "", .F.)
      o := "A_1187|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1187", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", "", .T.)
      o := "A_1188|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1188", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", "", .T., .T.)
      o := "A_1189|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1189", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a ,b , c", "", .T., .F.)
      o := "A_1190|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1190", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc")
      o := "A_1191|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1191", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", NIL, .F.)
      o := "A_1192|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1192", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", NIL, .T.)
      o := "A_1193|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1193", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", NIL, .T., .T.)
      o := "A_1194|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1194", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", NIL, .T., .F.)
      o := "A_1195|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1195", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", " ")
      o := "A_1196|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1196", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", " ", .F.)
      o := "A_1197|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1197", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", " ", .T.)
      o := "A_1198|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1198", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", " ", .T., .T.)
      o := "A_1199|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1199", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", " ", .T., .F.)
      o := "A_1200|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1200", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P040()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ",")
      o := "A_1201|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1201", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ",", .F.)
      o := "A_1202|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1202", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ",", .T.)
      o := "A_1203|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1203", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ",", .T., .T.)
      o := "A_1204|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1204", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ",", .T., .F.)
      o := "A_1205|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1205", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ", ")
      o := "A_1206|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1206", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ", ", .F.)
      o := "A_1207|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1207", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ", ", .T.)
      o := "A_1208|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1208", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ", ", .T., .T.)
      o := "A_1209|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1209", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ", ", .T., .F.)
      o := "A_1210|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1210", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ";")
      o := "A_1211|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1211", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ";", .F.)
      o := "A_1212|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1212", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ";", .T.)
      o := "A_1213|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1213", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ";", .T., .T.)
      o := "A_1214|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1214", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", ";", .T., .F.)
      o := "A_1215|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1215", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", "::")
      o := "A_1216|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1216", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", "::", .F.)
      o := "A_1217|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1217", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", "::", .T.)
      o := "A_1218|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1218", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", "::", .T., .T.)
      o := "A_1219|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1219", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", "::", .T., .F.)
      o := "A_1220|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1220", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", "")
      o := "A_1221|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1221", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", "", .F.)
      o := "A_1222|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1222", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", "", .T.)
      o := "A_1223|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1223", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", "", .T., .T.)
      o := "A_1224|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1224", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc", "", .T., .F.)
      o := "A_1225|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1225", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b")
      o := "A_1226|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1226", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", NIL, .F.)
      o := "A_1227|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1227", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", NIL, .T.)
      o := "A_1228|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1228", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", NIL, .T., .T.)
      o := "A_1229|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1229", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", NIL, .T., .F.)
      o := "A_1230|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1230", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P041()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", " ")
      o := "A_1231|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1231", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", " ", .F.)
      o := "A_1232|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1232", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", " ", .T.)
      o := "A_1233|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1233", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", " ", .T., .T.)
      o := "A_1234|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1234", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", " ", .T., .F.)
      o := "A_1235|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1235", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ",")
      o := "A_1236|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1236", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ",", .F.)
      o := "A_1237|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1237", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ",", .T.)
      o := "A_1238|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1238", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ",", .T., .T.)
      o := "A_1239|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1239", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ",", .T., .F.)
      o := "A_1240|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1240", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ", ")
      o := "A_1241|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1241", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ", ", .F.)
      o := "A_1242|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1242", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ", ", .T.)
      o := "A_1243|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1243", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ", ", .T., .T.)
      o := "A_1244|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1244", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ", ", .T., .F.)
      o := "A_1245|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1245", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ";")
      o := "A_1246|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1246", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ";", .F.)
      o := "A_1247|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1247", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ";", .T.)
      o := "A_1248|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1248", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ";", .T., .T.)
      o := "A_1249|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1249", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", ";", .T., .F.)
      o := "A_1250|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1250", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", "::")
      o := "A_1251|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1251", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", "::", .F.)
      o := "A_1252|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1252", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", "::", .T.)
      o := "A_1253|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1253", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", "::", .T., .T.)
      o := "A_1254|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1254", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", "::", .T., .F.)
      o := "A_1255|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1255", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", "")
      o := "A_1256|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1256", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", "", .F.)
      o := "A_1257|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1257", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", "", .T.)
      o := "A_1258|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1258", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", "", .T., .T.)
      o := "A_1259|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1259", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b", "", .T., .F.)
      o := "A_1260|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1260", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P042()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y")
      o := "A_1261|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1261", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", NIL, .F.)
      o := "A_1262|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1262", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", NIL, .T.)
      o := "A_1263|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1263", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", NIL, .T., .T.)
      o := "A_1264|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1264", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", NIL, .T., .F.)
      o := "A_1265|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1265", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", " ")
      o := "A_1266|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1266", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", " ", .F.)
      o := "A_1267|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1267", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", " ", .T.)
      o := "A_1268|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1268", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", " ", .T., .T.)
      o := "A_1269|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1269", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", " ", .T., .F.)
      o := "A_1270|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1270", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ",")
      o := "A_1271|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1271", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ",", .F.)
      o := "A_1272|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1272", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ",", .T.)
      o := "A_1273|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1273", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ",", .T., .T.)
      o := "A_1274|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1274", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ",", .T., .F.)
      o := "A_1275|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1275", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ", ")
      o := "A_1276|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1276", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ", ", .F.)
      o := "A_1277|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1277", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ", ", .T.)
      o := "A_1278|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1278", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ", ", .T., .T.)
      o := "A_1279|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1279", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ", ", .T., .F.)
      o := "A_1280|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1280", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ";")
      o := "A_1281|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1281", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ";", .F.)
      o := "A_1282|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1282", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ";", .T.)
      o := "A_1283|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1283", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ";", .T., .T.)
      o := "A_1284|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1284", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", ";", .T., .F.)
      o := "A_1285|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1285", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", "::")
      o := "A_1286|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1286", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", "::", .F.)
      o := "A_1287|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1287", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", "::", .T.)
      o := "A_1288|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1288", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", "::", .T., .T.)
      o := "A_1289|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1289", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", "::", .T., .F.)
      o := "A_1290|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1290", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P043()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", "")
      o := "A_1291|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1291", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", "", .F.)
      o := "A_1292|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1292", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", "", .T.)
      o := "A_1293|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1293", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", "", .T., .T.)
      o := "A_1294|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1294", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("'single, quoted' x,y", "", .T., .F.)
      o := "A_1295|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1295", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three")
      o := "A_1296|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1296", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", NIL, .F.)
      o := "A_1297|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1297", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", NIL, .T.)
      o := "A_1298|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1298", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", NIL, .T., .T.)
      o := "A_1299|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1299", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", NIL, .T., .F.)
      o := "A_1300|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1300", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", " ")
      o := "A_1301|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1301", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", " ", .F.)
      o := "A_1302|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1302", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", " ", .T.)
      o := "A_1303|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1303", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", " ", .T., .T.)
      o := "A_1304|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1304", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", " ", .T., .F.)
      o := "A_1305|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1305", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ",")
      o := "A_1306|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1306", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ",", .F.)
      o := "A_1307|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1307", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ",", .T.)
      o := "A_1308|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1308", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ",", .T., .T.)
      o := "A_1309|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1309", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ",", .T., .F.)
      o := "A_1310|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1310", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ", ")
      o := "A_1311|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1311", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ", ", .F.)
      o := "A_1312|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1312", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ", ", .T.)
      o := "A_1313|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1313", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ", ", .T., .T.)
      o := "A_1314|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1314", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ", ", .T., .F.)
      o := "A_1315|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1315", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ";")
      o := "A_1316|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1316", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ";", .F.)
      o := "A_1317|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1317", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ";", .T.)
      o := "A_1318|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1318", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ";", .T., .T.)
      o := "A_1319|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1319", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", ";", .T., .F.)
      o := "A_1320|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1320", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P044()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", "::")
      o := "A_1321|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1321", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", "::", .F.)
      o := "A_1322|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1322", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", "::", .T.)
      o := "A_1323|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1323", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", "::", .T., .T.)
      o := "A_1324|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1324", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", "::", .T., .F.)
      o := "A_1325|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1325", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", "")
      o := "A_1326|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1326", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", "", .F.)
      o := "A_1327|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1327", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", "", .T.)
      o := "A_1328|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1328", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", "", .T., .T.)
      o := "A_1329|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1329", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Chr(34) + "dq, one" + Chr(34) + ",'sq, two',three", "", .T., .F.)
      o := "A_1330|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1330", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c")
      o := "A_1331|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1331", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", NIL, .F.)
      o := "A_1332|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1332", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", NIL, .T.)
      o := "A_1333|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1333", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", NIL, .T., .T.)
      o := "A_1334|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1334", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", NIL, .T., .F.)
      o := "A_1335|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1335", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", " ")
      o := "A_1336|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1336", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", " ", .F.)
      o := "A_1337|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1337", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", " ", .T.)
      o := "A_1338|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1338", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", " ", .T., .T.)
      o := "A_1339|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1339", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", " ", .T., .F.)
      o := "A_1340|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1340", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ",")
      o := "A_1341|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1341", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ",", .F.)
      o := "A_1342|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1342", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ",", .T.)
      o := "A_1343|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1343", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ",", .T., .T.)
      o := "A_1344|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1344", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ",", .T., .F.)
      o := "A_1345|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1345", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ", ")
      o := "A_1346|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1346", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ", ", .F.)
      o := "A_1347|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1347", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ", ", .T.)
      o := "A_1348|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1348", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ", ", .T., .T.)
      o := "A_1349|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1349", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ", ", .T., .F.)
      o := "A_1350|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1350", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P045()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ";")
      o := "A_1351|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1351", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ";", .F.)
      o := "A_1352|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1352", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ";", .T.)
      o := "A_1353|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1353", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ";", .T., .T.)
      o := "A_1354|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1354", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", ";", .T., .F.)
      o := "A_1355|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1355", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", "::")
      o := "A_1356|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1356", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", "::", .F.)
      o := "A_1357|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1357", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", "::", .T.)
      o := "A_1358|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1358", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", "::", .T., .T.)
      o := "A_1359|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1359", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", "::", .T., .F.)
      o := "A_1360|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1360", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", "")
      o := "A_1361|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1361", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", "", .F.)
      o := "A_1362|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1362", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", "", .T.)
      o := "A_1363|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1363", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", "", .T., .T.)
      o := "A_1364|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1364", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(0) + "b c", "", .T., .F.)
      o := "A_1365|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1365", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double")
      o := "A_1366|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1366", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", NIL, .F.)
      o := "A_1367|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1367", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", NIL, .T.)
      o := "A_1368|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1368", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", NIL, .T., .T.)
      o := "A_1369|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1369", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", NIL, .T., .F.)
      o := "A_1370|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1370", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", " ")
      o := "A_1371|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1371", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", " ", .F.)
      o := "A_1372|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1372", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", " ", .T.)
      o := "A_1373|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1373", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", " ", .T., .T.)
      o := "A_1374|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1374", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", " ", .T., .F.)
      o := "A_1375|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1375", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ",")
      o := "A_1376|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1376", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ",", .F.)
      o := "A_1377|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1377", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ",", .T.)
      o := "A_1378|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1378", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ",", .T., .T.)
      o := "A_1379|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1379", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ",", .T., .F.)
      o := "A_1380|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1380", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P046()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ", ")
      o := "A_1381|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1381", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ", ", .F.)
      o := "A_1382|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1382", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ", ", .T.)
      o := "A_1383|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1383", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ", ", .T., .T.)
      o := "A_1384|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1384", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ", ", .T., .F.)
      o := "A_1385|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1385", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ";")
      o := "A_1386|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1386", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ";", .F.)
      o := "A_1387|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1387", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ";", .T.)
      o := "A_1388|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1388", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ";", .T., .T.)
      o := "A_1389|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1389", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", ";", .T., .F.)
      o := "A_1390|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1390", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", "::")
      o := "A_1391|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1391", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", "::", .F.)
      o := "A_1392|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1392", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", "::", .T.)
      o := "A_1393|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1393", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", "::", .T., .T.)
      o := "A_1394|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1394", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", "::", .T., .F.)
      o := "A_1395|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1395", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", "")
      o := "A_1396|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1396", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", "", .F.)
      o := "A_1397|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1397", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", "", .T.)
      o := "A_1398|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1398", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", "", .T., .T.)
      o := "A_1399|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1399", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("tab" + Chr(9) + Chr(9) + "double", "", .T., .F.)
      o := "A_1400|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1400", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x")
      o := "A_1401|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1401", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", NIL, .F.)
      o := "A_1402|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1402", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", NIL, .T.)
      o := "A_1403|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1403", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", NIL, .T., .T.)
      o := "A_1404|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1404", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", NIL, .T., .F.)
      o := "A_1405|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1405", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", " ")
      o := "A_1406|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1406", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", " ", .F.)
      o := "A_1407|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1407", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", " ", .T.)
      o := "A_1408|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1408", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", " ", .T., .T.)
      o := "A_1409|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1409", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", " ", .T., .F.)
      o := "A_1410|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1410", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P047()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ",")
      o := "A_1411|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1411", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ",", .F.)
      o := "A_1412|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1412", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ",", .T.)
      o := "A_1413|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1413", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ",", .T., .T.)
      o := "A_1414|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1414", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ",", .T., .F.)
      o := "A_1415|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1415", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ", ")
      o := "A_1416|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1416", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ", ", .F.)
      o := "A_1417|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1417", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ", ", .T.)
      o := "A_1418|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1418", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ", ", .T., .T.)
      o := "A_1419|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1419", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ", ", .T., .F.)
      o := "A_1420|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1420", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ";")
      o := "A_1421|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1421", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ";", .F.)
      o := "A_1422|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1422", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ";", .T.)
      o := "A_1423|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1423", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ";", .T., .T.)
      o := "A_1424|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1424", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", ";", .T., .F.)
      o := "A_1425|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1425", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", "::")
      o := "A_1426|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1426", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", "::", .F.)
      o := "A_1427|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1427", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", "::", .T.)
      o := "A_1428|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1428", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", "::", .T., .T.)
      o := "A_1429|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1429", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", "::", .T., .F.)
      o := "A_1430|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1430", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", "")
      o := "A_1431|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1431", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", "", .F.)
      o := "A_1432|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1432", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", "", .T.)
      o := "A_1433|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1433", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", "", .T., .T.)
      o := "A_1434|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1434", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x", "", .T., .F.)
      o := "A_1435|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1435", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail")
      o := "A_1436|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1436", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", NIL, .F.)
      o := "A_1437|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1437", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", NIL, .T.)
      o := "A_1438|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1438", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", NIL, .T., .T.)
      o := "A_1439|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1439", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", NIL, .T., .F.)
      o := "A_1440|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1440", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P048()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", " ")
      o := "A_1441|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1441", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", " ", .F.)
      o := "A_1442|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1442", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", " ", .T.)
      o := "A_1443|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1443", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", " ", .T., .T.)
      o := "A_1444|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1444", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", " ", .T., .F.)
      o := "A_1445|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1445", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ",")
      o := "A_1446|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1446", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ",", .F.)
      o := "A_1447|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1447", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ",", .T.)
      o := "A_1448|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1448", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ",", .T., .T.)
      o := "A_1449|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1449", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ",", .T., .F.)
      o := "A_1450|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1450", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ", ")
      o := "A_1451|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1451", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ", ", .F.)
      o := "A_1452|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1452", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ", ", .T.)
      o := "A_1453|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1453", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ", ", .T., .T.)
      o := "A_1454|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1454", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ", ", .T., .F.)
      o := "A_1455|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1455", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ";")
      o := "A_1456|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1456", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ";", .F.)
      o := "A_1457|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1457", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ";", .T.)
      o := "A_1458|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1458", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ";", .T., .T.)
      o := "A_1459|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1459", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", ";", .T., .F.)
      o := "A_1460|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1460", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", "::")
      o := "A_1461|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1461", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", "::", .F.)
      o := "A_1462|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1462", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", "::", .T.)
      o := "A_1463|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1463", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", "::", .T., .T.)
      o := "A_1464|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1464", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", "::", .T., .F.)
      o := "A_1465|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1465", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", "")
      o := "A_1466|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1466", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", "", .F.)
      o := "A_1467|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1467", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", "", .T.)
      o := "A_1468|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1468", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", "", .T., .T.)
      o := "A_1469|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1469", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("   " + Chr(34) + "lead space" + Chr(34) + " tail", "", .T., .F.)
      o := "A_1470|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1470", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P049()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34))
      o := "A_1471|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1471", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), NIL, .F.)
      o := "A_1472|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1472", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), NIL, .T.)
      o := "A_1473|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1473", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), NIL, .T., .T.)
      o := "A_1474|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1474", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), NIL, .T., .F.)
      o := "A_1475|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1475", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), " ")
      o := "A_1476|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1476", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), " ", .F.)
      o := "A_1477|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1477", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), " ", .T.)
      o := "A_1478|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1478", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), " ", .T., .T.)
      o := "A_1479|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1479", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), " ", .T., .F.)
      o := "A_1480|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1480", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ",")
      o := "A_1481|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1481", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ",", .F.)
      o := "A_1482|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1482", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ",", .T.)
      o := "A_1483|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1483", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ",", .T., .T.)
      o := "A_1484|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1484", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ",", .T., .F.)
      o := "A_1485|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1485", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ", ")
      o := "A_1486|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1486", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ", ", .F.)
      o := "A_1487|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1487", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ", ", .T.)
      o := "A_1488|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1488", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ", ", .T., .T.)
      o := "A_1489|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1489", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ", ", .T., .F.)
      o := "A_1490|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1490", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ";")
      o := "A_1491|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1491", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ";", .F.)
      o := "A_1492|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1492", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ";", .T.)
      o := "A_1493|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1493", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ";", .T., .T.)
      o := "A_1494|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1494", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), ";", .T., .F.)
      o := "A_1495|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1495", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), "::")
      o := "A_1496|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1496", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), "::", .F.)
      o := "A_1497|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1497", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), "::", .T.)
      o := "A_1498|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1498", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), "::", .T., .T.)
      o := "A_1499|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1499", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), "::", .T., .F.)
      o := "A_1500|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1500", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P050()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), "")
      o := "A_1501|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1501", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), "", .F.)
      o := "A_1502|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1502", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), "", .T.)
      o := "A_1503|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1503", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), "", .T., .T.)
      o := "A_1504|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1504", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("trail " + Chr(34) + "q" + Chr(34), "", .T., .F.)
      o := "A_1505|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "A_1505", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c","a")
      o := "B_1506|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1506", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c","ab")
      o := "B_1507|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1507", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c","b")
      o := "B_1508|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1508", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c",Chr(9))
      o := "B_1509|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1509", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c",Chr(13)+Chr(10))
      o := "B_1510|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1510", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c",Chr(10))
      o := "B_1511|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1511", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c","  ")
      o := "B_1512|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1512", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c","abc")
      o := "B_1513|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1513", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c","abcabc")
      o := "B_1514|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1514", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c","::")
      o := "B_1515|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1515", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c",":")
      o := "B_1516|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1516", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c"," ,")
      o := "B_1517|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1517", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b  c","zz")
      o := "B_1518|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1518", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c","a")
      o := "B_1519|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1519", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c","ab")
      o := "B_1520|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1520", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c","b")
      o := "B_1521|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1521", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c",Chr(9))
      o := "B_1522|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1522", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c",Chr(13)+Chr(10))
      o := "B_1523|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1523", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c",Chr(10))
      o := "B_1524|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1524", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c","  ")
      o := "B_1525|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1525", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c","abc")
      o := "B_1526|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1526", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c","abcabc")
      o := "B_1527|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1527", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c","::")
      o := "B_1528|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1528", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c",":")
      o := "B_1529|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1529", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c"," ,")
      o := "B_1530|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1530", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P051()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a,b,,c","zz")
      o := "B_1531|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1531", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc","a")
      o := "B_1532|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1532", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc","ab")
      o := "B_1533|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1533", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc","b")
      o := "B_1534|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1534", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc",Chr(9))
      o := "B_1535|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1535", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc",Chr(13)+Chr(10))
      o := "B_1536|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1536", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc",Chr(10))
      o := "B_1537|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1537", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc","  ")
      o := "B_1538|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1538", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc","abc")
      o := "B_1539|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1539", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc","abcabc")
      o := "B_1540|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1540", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc","::")
      o := "B_1541|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1541", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc",":")
      o := "B_1542|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1542", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc"," ,")
      o := "B_1543|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1543", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("abcabc","zz")
      o := "B_1544|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1544", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d","a")
      o := "B_1545|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1545", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d","ab")
      o := "B_1546|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1546", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d","b")
      o := "B_1547|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1547", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d",Chr(9))
      o := "B_1548|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1548", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d",Chr(13)+Chr(10))
      o := "B_1549|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1549", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d",Chr(10))
      o := "B_1550|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1550", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d","  ")
      o := "B_1551|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1551", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d","abc")
      o := "B_1552|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1552", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d","abcabc")
      o := "B_1553|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1553", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d","::")
      o := "B_1554|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1554", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d",":")
      o := "B_1555|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1555", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d"," ,")
      o := "B_1556|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1556", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a" + Chr(9) + "b c" + Chr(10) + "d","zz")
      o := "B_1557|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1557", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z","a")
      o := "B_1558|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1558", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z","ab")
      o := "B_1559|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1559", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z","b")
      o := "B_1560|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1560", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P052()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z",Chr(9))
      o := "B_1561|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1561", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z",Chr(13)+Chr(10))
      o := "B_1562|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1562", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z",Chr(10))
      o := "B_1563|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1563", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z","  ")
      o := "B_1564|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1564", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z","abc")
      o := "B_1565|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1565", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z","abcabc")
      o := "B_1566|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1566", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z","::")
      o := "B_1567|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1567", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z",":")
      o := "B_1568|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1568", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z"," ,")
      o := "B_1569|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1569", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("x::y::z","zz")
      o := "B_1570|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1570", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c","a")
      o := "B_1571|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1571", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c","ab")
      o := "B_1572|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1572", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c","b")
      o := "B_1573|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1573", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c",Chr(9))
      o := "B_1574|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1574", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c",Chr(13)+Chr(10))
      o := "B_1575|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1575", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c",Chr(10))
      o := "B_1576|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1576", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c","  ")
      o := "B_1577|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1577", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c","abc")
      o := "B_1578|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1578", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c","abcabc")
      o := "B_1579|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1579", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c","::")
      o := "B_1580|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1580", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c",":")
      o := "B_1581|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1581", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c"," ,")
      o := "B_1582|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1582", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a  b   c","zz")
      o := "B_1583|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1583", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four","a")
      o := "B_1584|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1584", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four","ab")
      o := "B_1585|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1585", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four","b")
      o := "B_1586|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1586", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four",Chr(9))
      o := "B_1587|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1587", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four",Chr(13)+Chr(10))
      o := "B_1588|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1588", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four",Chr(10))
      o := "B_1589|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1589", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four","  ")
      o := "B_1590|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1590", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P053()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four","abc")
      o := "B_1591|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1591", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four","abcabc")
      o := "B_1592|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1592", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four","::")
      o := "B_1593|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1593", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four",":")
      o := "B_1594|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1594", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four"," ,")
      o := "B_1595|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1595", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("one two" + Chr(9) + "three" + Chr(10) + "four","zz")
      o := "B_1596|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "B_1596", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",NIL)
      o := "C_1597|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1597", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",NIL)
      o := "C_1598|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1598", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",.T.,NIL)
      o := "C_1599|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1599", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(NIL,",")
      o := "C_1600|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1600", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(NIL)
      o := "C_1601|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1601", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",44)
      o := "C_1602|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1602", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",44)
      o := "C_1603|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1603", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",.T.,44)
      o := "C_1604|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1604", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(44,",")
      o := "C_1605|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1605", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(44)
      o := "C_1606|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1606", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",.T.)
      o := "C_1607|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1607", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",.T.)
      o := "C_1608|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1608", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",.T.,.T.)
      o := "C_1609|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1609", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(.T.,",")
      o := "C_1610|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1610", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(.T.)
      o := "C_1611|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1611", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",.F.)
      o := "C_1612|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1612", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",.F.)
      o := "C_1613|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1613", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",.T.,.F.)
      o := "C_1614|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1614", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(.F.,",")
      o := "C_1615|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1615", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(.F.)
      o := "C_1616|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1616", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",{})
      o := "C_1617|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1617", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",{})
      o := "C_1618|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1618", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",.T.,{})
      o := "C_1619|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1619", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens({},",")
      o := "C_1620|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1620", e )
   END SEQUENCE
   RETURN
STATIC PROCEDURE P054()
   LOCAL r := hb_ATokens("x") // ADAPTED: typed seat for the DArrS result (reassigned per case)
   LOCAL i := 0, o := "", s := "", e
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens({})
      o := "C_1621|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1621", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",Date())
      o := "C_1622|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1622", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",Date())
      o := "C_1623|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1623", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",.T.,Date())
      o := "C_1624|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1624", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Date(),",")
      o := "C_1625|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1625", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Date())
      o := "C_1626|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1626", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",1.5)
      o := "C_1627|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1627", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",1.5)
      o := "C_1628|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1628", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",.T.,1.5)
      o := "C_1629|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1629", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(1.5,",")
      o := "C_1630|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1630", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(1.5)
      o := "C_1631|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1631", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",{||1})
      o := "C_1632|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1632", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",{||1})
      o := "C_1633|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1633", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b,c",",",.T.,{||1})
      o := "C_1634|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1634", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens({||1},",")
      o := "C_1635|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1635", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens({||1})
      o := "C_1636|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1636", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b",.T.)
      o := "C_1637|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1637", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a " + Chr(34) + "b c" + Chr(34) + " d",.T.)
      o := "C_1638|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1638", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b",NIL,.T.)
      o := "C_1639|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1639", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b",NIL,NIL,.T.)
      o := "C_1640|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "C_1640", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens() // ADAPTED: direct call, macro row D_1641
      o := "D_1641|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "D_1641", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b",",",.T.,.T.,1) // ADAPTED: direct call, macro row D_1642
      o := "D_1642|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "D_1642", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b",",",.T.,.T.,1,2) // ADAPTED: direct call, macro row D_1643
      o := "D_1643|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "D_1643", e )
   END SEQUENCE
   // ADAPTED: row D_1644 (ATokens undefined) is pinned by a compile-time reject probe, not an output row
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b",NIL,.T.) // ADAPTED: direct call + explicit NIL, macro row D_1645
      o := "D_1645|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "D_1645", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens("a b",NIL,NIL,.T.) // ADAPTED: direct call + explicit NIL, macro row D_1646
      o := "D_1646|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "D_1646", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Replicate("ab ",1000))
      o := "E_1647|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "E_1647", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Replicate("a,",1000),",")
      o := "E_1648|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "E_1648", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Replicate("x",5000)+" y")
      o := "E_1649|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "E_1649", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := hb_ATokens(Replicate("a,",2000)+"z",",")
      o := "E_1650|A|" + hb_ntos( Len( r ) )
      FOR i := 1 TO Len( r )
         s := r[ i ]
         o += "|" + hb_ntos( Len( s ) ) + ":[" + Esc( s ) + "]"
         s := ""
      NEXT
      OutStd( o + hb_eol() )
   RECOVER USING e
      Err( "E_1650", e )
   END SEQUENCE
   RETURN

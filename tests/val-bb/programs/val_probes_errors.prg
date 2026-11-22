// Caught-description probes: every Val argument error must be a
// catchable "Argument error" (oracle C/D rows; the spec Err() relies
// on it). A mismatch prints a visible marker and fails the byte compare.
STATIC PROCEDURE Rep( id, e )
   IF hb_CStr( e ) == "Argument error"
      OutStd( id + "|caught ok" + hb_eol() )
   ELSE
      OutStd( id + "|ERR-DESC-MISMATCH|[" + hb_CStr( e ) + "]" + hb_eol() )
   ENDIF
   RETURN
PROCEDURE Main()
   LOCAL r := Val("0")
   LOCAL e
   BEGIN SEQUENCE WITH {| b | Break( b ) }
      r := Val( NIL )
      OutStd( "caught1|NO-ERROR" + hb_eol() )
   RECOVER USING e
      Rep( "caught1", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| b | Break( b ) }
      r := Val( 5 )
      OutStd( "caught2|NO-ERROR" + hb_eol() )
   RECOVER USING e
      Rep( "caught2", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| b | Break( b ) }
      r := Val( 5.5 )
      OutStd( "caught3|NO-ERROR" + hb_eol() )
   RECOVER USING e
      Rep( "caught3", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| b | Break( b ) }
      r := Val( .T. )
      OutStd( "caught4|NO-ERROR" + hb_eol() )
   RECOVER USING e
      Rep( "caught4", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| b | Break( b ) }
      r := Val( Date() )
      OutStd( "caught5|NO-ERROR" + hb_eol() )
   RECOVER USING e
      Rep( "caught5", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| b | Break( b ) }
      r := Val( {||1} )
      OutStd( "caught6|NO-ERROR" + hb_eol() )
   RECOVER USING e
      Rep( "caught6", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| b | Break( b ) }
      r := Val()
      OutStd( "caught7|NO-ERROR" + hb_eol() )
   RECOVER USING e
      Rep( "caught7", e )
   END SEQUENCE
   RETURN

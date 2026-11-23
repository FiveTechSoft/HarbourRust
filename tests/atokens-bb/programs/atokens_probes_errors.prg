// Caught-description probes: every hb_ATokens argument error must be a
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
   LOCAL r := hb_ATokens("x")
   LOCAL e
   BEGIN SEQUENCE WITH {| b | Break( b ) }
      r := hb_ATokens( 44 )
      OutStd( "caught1|NO-ERROR" + hb_eol() )
   RECOVER USING e
      Rep( "caught1", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| b | Break( b ) }
      r := hb_ATokens( Date() )
      OutStd( "caught2|NO-ERROR" + hb_eol() )
   RECOVER USING e
      Rep( "caught2", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| b | Break( b ) }
      r := hb_ATokens( {||1} )
      OutStd( "caught3|NO-ERROR" + hb_eol() )
   RECOVER USING e
      Rep( "caught3", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| b | Break( b ) }
      r := hb_ATokens( .T. )
      OutStd( "caught4|NO-ERROR" + hb_eol() )
   RECOVER USING e
      Rep( "caught4", e )
   END SEQUENCE
   BEGIN SEQUENCE WITH {| b | Break( b ) }
      r := hb_ATokens()
      OutStd( "caught5|NO-ERROR" + hb_eol() )
   RECOVER USING e
      Rep( "caught5", e )
   END SEQUENCE
   RETURN

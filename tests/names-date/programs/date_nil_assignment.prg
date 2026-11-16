PROCEDURE Main()
   Probe( SToD( "20200101" ) )
RETURN
PROCEDURE Probe( d )
   IF ValType( d ) != "D"
      d := Date()
   ENDIF
   ? DToS( d )
RETURN

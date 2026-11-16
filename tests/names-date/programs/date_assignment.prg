PROCEDURE Main()
   Probe( SToD( "20200101" ) )
RETURN
PROCEDURE Probe( d )
   d := Date()
   ? d == Date(), ValType( d )
RETURN

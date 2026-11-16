// Fixture builder: compiled by real Harbour only (hbc never writes DBFs).
PROCEDURE Main()
   LOCAL a := { { "ANA", 34, 1250.50, .T., "20260115" }, ;
                { "LUIS", 45, -3.25, .F., "20251231" }, ;
                { "Ma Jose", 7, 0, .T., "" } }, r
   dbCreate( "fields.dbf", { { "NOMBRE", "C", 12, 0 }, { "EDAD", "N", 3, 0 }, ;
      { "SALDO", "N", 8, 2 }, { "ACTIVO", "L", 1, 0 }, { "ALTA", "D", 8, 0 } } )
   dbUseArea( .T., "DBFNTX", "fields.dbf", "FX", .F., .F. )
   FOR EACH r IN a
      dbAppend()
      FieldPut( 1, r[ 1 ] ) ; FieldPut( 2, r[ 2 ] ) ; FieldPut( 3, r[ 3 ] )
      FieldPut( 4, r[ 4 ] ) ; FieldPut( 5, hb_SToD( r[ 5 ] ) )
   NEXT
   dbCloseArea()
RETURN

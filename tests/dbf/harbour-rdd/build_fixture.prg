// Fixture builder: compiled by real Harbour only. Two tables written by
// Harbour itself: clie.dbf (+ clie.fpt memo, DBFCDX) and clin.dbf (DBFNTX).
REQUEST DBFCDX
REQUEST DBFNTX
PROCEDURE Main()
   LOCAL a := { { "ANA", 34, 1250.50, .T., "20260115", "primera nota" }, ;
                { "LUIS", 45, -3.25, .F., "20251231", "" }, ;
                { "Ma Jose", 7, 0, .T., "", "tercera" } }, r
   LOCAL s := { { "NOMBRE", "C", 12, 0 }, { "EDAD", "N", 3, 0 }, ;
                { "SALDO", "N", 8, 2 }, { "ACTIVO", "L", 1, 0 }, { "ALTA", "D", 8, 0 } }
   dbCreate( "clin.dbf", s, "DBFNTX" )
   AAdd( s, { "NOTA", "M", 10, 0 } )
   dbCreate( "clie.dbf", s, "DBFCDX" )
   dbUseArea( .T., "DBFCDX", "clie.dbf", "CLIE", .F., .F. )
   dbUseArea( .T., "DBFNTX", "clin.dbf", "CLIN", .F., .F. )
   FOR EACH r IN a
      CLIE->( dbAppend() )
      CLIE->( FieldPut( 1, r[ 1 ] ) ) ; CLIE->( FieldPut( 2, r[ 2 ] ) ) ; CLIE->( FieldPut( 3, r[ 3 ] ) )
      CLIE->( FieldPut( 4, r[ 4 ] ) ) ; CLIE->( FieldPut( 5, hb_SToD( r[ 5 ] ) ) ) ; CLIE->( FieldPut( 6, r[ 6 ] ) )
      CLIN->( dbAppend() )
      CLIN->( FieldPut( 1, r[ 1 ] ) ) ; CLIN->( FieldPut( 2, r[ 2 ] ) ) ; CLIN->( FieldPut( 3, r[ 3 ] ) )
      CLIN->( FieldPut( 4, r[ 4 ] ) ) ; CLIN->( FieldPut( 5, hb_SToD( r[ 5 ] ) ) )
   NEXT
   dbCloseAll()
RETURN

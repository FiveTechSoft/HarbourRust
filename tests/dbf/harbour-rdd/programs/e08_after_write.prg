// compare: rc,files
// hbc's own bound-error report differs from Harbour's in every mode
// (pre-existing, not RDD); this case checks that hbc's panic exit still
// flushes the table through hb_vmQuit.
PROCEDURE Main()
   LOCAL a := { 1, 2 }
   dbUseArea(.T.,"DBFNTX","clin.dbf","CLIN",.F.,.F.)
   dbAppend()
   FIELD->NOMBRE := "ANTES DEL ERROR"
   FIELD->EDAD := 12
   ? a[ Idx() ]
RETURN

FUNCTION Idx()
RETURN 3

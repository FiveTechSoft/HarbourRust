REQUEST DBFCDX
// D2 native write acceptance (test4): REPLACE WITH, alias->campo :=,
// FieldPut(n,...), dbAppend and persistence across dbCloseArea.
// Runs on a COPY of tests/dbf/acceptance-test3/M_CLIE.DBF (anonimizado).
// NOTE: decimal field arithmetic (SALDO+1) is outside hbc's Dyn integer
// arithmetic in both adapters; integer arithmetic and double literals are
// Harbour-exact here.
procedure main()
  dbUseArea(.T., "DBFCDX", "m_clie.dbf", "CLIE", .F., .F.)
  replace LIMITE with CLIE->LIMITE + 1
  CLIE->SALDO := 1001.05
  FieldPut(8, SToD("20261116"))
  ? CLIE->SALDO, CLIE->LIMITE, CLIE->ALTA
  dbAppend()
  CLIE->CLIENTE := "000099"
  CLIE->NOMBRE := "APPEND D2"
  CLIE->SALDO := 12.5
  ? LastRec(), CLIE->CLIENTE, CLIE->NOMBRE, CLIE->SALDO
  dbCloseArea()
  dbUseArea(.T., "DBFCDX", "m_clie.dbf", "CLIE", .F., .F.)
  ? CLIE->SALDO, CLIE->LIMITE, CLIE->ALTA
  dbGoBottom()
  ? RecNo(), CLIE->CLIENTE, CLIE->NOMBRE, CLIE->SALDO
  dbCloseArea()
return

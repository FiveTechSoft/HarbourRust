REQUEST DBFCDX
// D3 native decimal arithmetic acceptance (test5): Dyn->F64 widening in
// +,-,*,/ over DBF decimal fields, Harbour dec rules, store rounding.
// Runs on a COPY of tests/dbf/acceptance-test3/M_CLIE.DBF (anonimizado).
procedure main()
  local x
  dbUseArea(.T., "DBFCDX", "m_clie.dbf", "CLIE", .F., .F.)
  ? CLIE->SALDO + 1
  ? 1 + CLIE->SALDO
  ? CLIE->SALDO + CLIE->SALDO
  ? CLIE->SALDO + 0.5
  ? CLIE->SALDO - 2000
  ? CLIE->SALDO * 2
  ? CLIE->SALDO * 1.5
  ? CLIE->SALDO / 2
  ? CLIE->SALDO + 1 * 2
  ? CLIE->LIMITE + 1
  ? CLIE->LIMITE * 1.5
  ? CLIE->LIMITE / 3
  x := CLIE->SALDO + 1
  ? x
  ? x + 0.5
  ? x * 2
  ? x / 3
  replace CLIE->SALDO with CLIE->SALDO + 1
  ? CLIE->SALDO
  dbSkip(1)
  replace CLIE->SALDO with CLIE->SALDO / 3
  ? CLIE->SALDO
  dbCloseArea()
  dbUseArea(.T., "DBFCDX", "m_clie.dbf", "CLIE", .F., .F.)
  ? CLIE->SALDO
  dbSkip(1)
  ? CLIE->SALDO
  dbCloseArea()
return

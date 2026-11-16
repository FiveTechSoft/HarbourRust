REQUEST DBFCDX
// D4 comparison acceptance (test6): =, <>, <, >, <=, >= over DBF decimal
// fields and Dyn float cells (D3 arithmetic results), by-value numerics.
procedure main()
  local x
  dbUseArea(.T., "DBFCDX", "m_clie.dbf", "CLIE", .F., .F.)
  ? CLIE->SALDO = 1000.05
  ? CLIE->SALDO = 1000.050
  ? CLIE->SALDO = 1000
  ? CLIE->SALDO > 1000
  ? CLIE->SALDO < 1000.06
  ? CLIE->SALDO <= 1000.05
  ? CLIE->SALDO >= 1000.06
  ? CLIE->SALDO <> 1000.05
  ? CLIE->LIMITE = 51000
  ? CLIE->LIMITE = 51000.0
  ? CLIE->LIMITE > CLIE->SALDO
  ? CLIE->SALDO = CLIE->SALDO
  x := CLIE->SALDO + 1
  ? x = 1001.05
  ? x > 1001
  ? x <= 1001.05
  ? x <> CLIE->SALDO
  ? CLIE->SALDO * 2 = 2000.10
  ? CLIE->SALDO - 2000 < 0
  dbSkip(1)
  ? CLIE->SALDO > 1000.05
  ? CLIE->SALDO = 2000.05
  dbCloseArea()
return

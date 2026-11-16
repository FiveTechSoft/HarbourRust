REQUEST DBFCDX
// D5 oracle: % and ^ over DBF decimal fields and Dyn float cells.
procedure main()
  local x, n
  dbUseArea(.T., "DBFCDX", "m_clie.dbf", "CLIE", .F., .F.)
  ? CLIE->SALDO % 3
  ? CLIE->SALDO % 100
  ? CLIE->LIMITE % 7
  ? CLIE->LIMITE % 51000
  x := CLIE->SALDO + 1
  ? x % 2
  ? x % 7
  ? -CLIE->SALDO % 3
  ? CLIE->SALDO % -3
  ? CLIE->SALDO ^ 2
  ? CLIE->LIMITE ^ 2
  ? CLIE->SALDO ^ 0.5
  ? CLIE->SALDO ^ 0
  ? CLIE->SALDO ^ 1
  ? x ^ 2
  ? x ^ 0.5
  n := -2
  ? n ^ 2
  ? n ^ 3
  ? CLIE->SALDO % 1
  dbSkip(1)
  ? CLIE->SALDO % 3
  ? CLIE->SALDO ^ 2
  dbCloseArea()
return

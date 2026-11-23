function main()
 local t := 0, k := 0
 dbUseArea(.T., "DBFCDX", "big.dbf", "BG", .F., .T.)
 ? LastRec()
 dbGoto(LastRec())
 ? RecNo(), BG->CCOD, BG->NVAL, BG->DFEC, BG->LFLG
 dbGoTop()
 do while !Eof()
  t := t + BG->NVAL
  if BG->LFLG
   k++
  endif
  dbSkip()
 enddo
 ? t, k
 dbGoto(310000)
 ? BG->CCOD, BG->CPAD
 dbCloseArea()
return nil

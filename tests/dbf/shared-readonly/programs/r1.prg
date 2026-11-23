function main()
 local n := 0
 dbUseArea(.T., "DBFCDX", "shr.dbf", "S", .T., .T.)
 ? "opened", LastRec()
 do while !File("go.flag") .and. n < 400
  hb_idleSleep(0.05)
  n++
 enddo
 ? LastRec(), RecNo(), S->CCOD, S->NINT
 dbSkip()
 ? RecNo(), S->CCOD
 dbGoBottom()
 ? RecNo(), S->CCOD
 dbGoto(4)
 ? RecNo(), Eof(), S->CCOD
 dbCloseArea()
return nil

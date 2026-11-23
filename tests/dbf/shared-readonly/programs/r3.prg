function main()
 local n := 0
 dbUseArea(.T., "DBFCDX", "shc.dbf", "S", .T., .T.)
 ? "opened", LastRec()
 do while !File("go.flag") .and. n < 400
  hb_idleSleep(0.05)
  n++
 enddo
 ? RecNo(), S->CCOD, S->NINT
 dbSkip()
 ? RecNo(), S->CCOD
 dbGoBottom()
 ? RecNo(), S->CCOD
 dbCloseArea()
return nil

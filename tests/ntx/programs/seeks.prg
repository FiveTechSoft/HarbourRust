function Main()
   local q := 0, soft := 0, last := 0, key := "" + ""
   dbUseArea(.T., "DBFNTX", "ntxprobe.dbf", "PROBE", .F., .T.)
   OrdListAdd("names.ntx")
   for q := 0 to 71
      key := "K" + iif(q<10,"00","0") + LTrim(Str(q))
      for soft := 0 to 1
         for last := 0 to 1
            ? "seek", key, soft, last, dbSeek(key,soft==1,last==1), RecNo()
         next
      next
   next
   dbCloseArea()
return nil

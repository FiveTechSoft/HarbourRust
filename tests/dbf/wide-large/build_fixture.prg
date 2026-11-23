REQUEST DBFCDX
procedure Main()
 local a, i, r, n
 rddSetDefault("DBFCDX")
 /* wide187: 187 fields cycling C/N/D/L, 5 records */
 a := {}
 for i := 1 to 187
   do case
   case i % 4 == 1; AAdd(a, {"F" + hb_ntos(i), "C", 10, 0})
   case i % 4 == 2; AAdd(a, {"F" + hb_ntos(i), "N", 12, 2})
   case i % 4 == 3; AAdd(a, {"F" + hb_ntos(i), "D", 8, 0})
   otherwise;       AAdd(a, {"F" + hb_ntos(i), "L", 1, 0})
   endcase
 next
 dbCreate("wide187.dbf", a)
 dbUseArea(.T.,, "wide187.dbf", "WA", .F., .F.)
 for r := 1 to 5
   dbAppend()
   for i := 1 to 187
     do case
     case i % 4 == 1; FieldPut(i, "R" + hb_ntos(r) + "C" + hb_ntos(i))
     case i % 4 == 2; FieldPut(i, r * 1000 + i + 0.25)
     case i % 4 == 3; FieldPut(i, hb_SToD("20260101") + r * 31 + i)
     otherwise;       FieldPut(i, (r + i) % 2 == 0)
     endcase
   next
 next
 dbCloseArea()
 /* wide2046: the most fields a DBF header holds, 3 records */
 a := {}
 for i := 1 to 2046
   AAdd(a, {"F" + hb_ntos(i), "C", 1, 0})
 next
 dbCreate("wide2046.dbf", a)
 dbUseArea(.T.,, "wide2046.dbf", "WB", .F., .F.)
 for r := 1 to 3
   dbAppend()
   for i := 1 to 2046
     FieldPut(i, Chr(65 + (r + i) % 26))
   next
 next
 dbCloseArea()
 /* big: 620000 records of 122 bytes, about 75.6 MB (over the old 64 MiB) */
 dbCreate("big.dbf", {{"CCOD","C",10,0},{"NVAL","N",12,2},{"DFEC","D",8,0},{"LFLG","L",1,0},{"CPAD","C",90,0}})
 dbUseArea(.T.,, "big.dbf", "WC", .F., .F.)
 n := 620000
 for r := 1 to n
   dbAppend()
   WC->CCOD := "K" + StrZero(r, 7)
   WC->NVAL := (r % 1000) + 0.5
   WC->DFEC := hb_SToD("20200101") + r % 3000
   WC->LFLG := r % 3 == 0
   WC->CPAD := Replicate(Chr(97 + r % 26), 90)
 next
 dbCloseArea()
 ? "built"
return

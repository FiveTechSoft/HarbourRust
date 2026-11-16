// Year 0000 is a valid (leap) year in Harbour (report against 0.11.4:
// SToD("00000101") became an empty date).
PROCEDURE Main()
   LOCAL a := SToD("00000101"), b := SToD("00000229"), c := SToD("00001231"), e := SToD("00010101")
   ? "[" + DToS(a) + "]", "[" + DToS(b) + "]", "[" + DToS(c) + "]"
   ? CDoW(c), CMonth(b), CDoW(SToD("00000301"))
   ? Empty(a), a < e, b > a
   ? "[" + DToS(a + 59) + "]", "[" + DToS(b + 1) + "]", "[" + DToS(e - 1) + "]", "[" + DToS(e - 366) + "]"
   ? e - a, c - b
   ? "[" + DToS(SToD("00000230")) + "]", "[" + DToS(SToD("00001301")) + "]"
   ? DToC(b)
RETURN

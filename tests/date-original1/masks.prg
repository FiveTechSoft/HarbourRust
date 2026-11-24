FUNCTION Main()
 LOCAL mask, input, old:=Set(4), i
 ? Set(4,"yyyy/dd/mm"),DToC(SToD("19990430"))
 ? Set(4,"ddd/mmm/yyyy"),DToC(SToD("19990430"))
 mask:="yyyy/dd/mm"
 input:="49/02/04"
 Set(5,1950)
 ? Set(4,mask), DToS(CToD(input)), DToC(SToD("19990430"))
 mask:="yy/dd/mm"
 ? Set(4,mask),Set(4),__SetCentury()
 ? "["+DToC(SToD(""))+"]"
 ? "["+DToC(SToD("00010101"))+"]"
 ? "["+DToC(SToD("19990109"))+"]"
 ? "["+DToC(SToD("20001212"))+"]"
 ? "["+DToC(SToD("20700929"))+"]"
 ? "["+DToC(SToD("99991231"))+"]"
 ? DToS(CToD("02/04/49"))
 ? DToS(CToD("49/02/04"))
 ? DToS(CToD("1999/30/04"))
 ? DToS(CToD("30/04/1999"))
 ? DToS(CToD("030/004/99"))
 ? DToS(CToD("123/123/99"))
 ? __SetCentury(.T.),Set(4),DToC(SToD("19990430"))
 ? __SetCentury(.F.),Set(4),DToC(SToD("19990430"))
 mask:="yYyY/dD/mM"
 ? Set(4,mask),Set(4),__SetCentury()
 ? "["+DToC(SToD(""))+"]"
 ? "["+DToC(SToD("00010101"))+"]"
 ? "["+DToC(SToD("19990109"))+"]"
 ? "["+DToC(SToD("20001212"))+"]"
 ? "["+DToC(SToD("20700929"))+"]"
 ? "["+DToC(SToD("99991231"))+"]"
 ? DToS(CToD("02/04/49"))
 ? DToS(CToD("49/02/04"))
 ? DToS(CToD("1999/30/04"))
 ? DToS(CToD("30/04/1999"))
 ? DToS(CToD("030/004/99"))
 ? DToS(CToD("123/123/99"))
 ? __SetCentury(.T.),Set(4),DToC(SToD("19990430"))
 ? __SetCentury(.F.),Set(4),DToC(SToD("19990430"))
 mask:="ddd/mmm/yy"
 ? Set(4,mask),Set(4),__SetCentury()
 ? "["+DToC(SToD(""))+"]"
 ? "["+DToC(SToD("00010101"))+"]"
 ? "["+DToC(SToD("19990109"))+"]"
 ? "["+DToC(SToD("20001212"))+"]"
 ? "["+DToC(SToD("20700929"))+"]"
 ? "["+DToC(SToD("99991231"))+"]"
 ? DToS(CToD("02/04/49"))
 ? DToS(CToD("49/02/04"))
 ? DToS(CToD("1999/30/04"))
 ? DToS(CToD("30/04/1999"))
 ? DToS(CToD("030/004/99"))
 ? DToS(CToD("123/123/99"))
 ? __SetCentury(.T.),Set(4),DToC(SToD("19990430"))
 ? __SetCentury(.F.),Set(4),DToC(SToD("19990430"))
 mask:="DdD/mMm/YyYy"
 ? Set(4,mask),Set(4),__SetCentury()
 ? "["+DToC(SToD(""))+"]"
 ? "["+DToC(SToD("00010101"))+"]"
 ? "["+DToC(SToD("19990109"))+"]"
 ? "["+DToC(SToD("20001212"))+"]"
 ? "["+DToC(SToD("20700929"))+"]"
 ? "["+DToC(SToD("99991231"))+"]"
 ? DToS(CToD("02/04/49"))
 ? DToS(CToD("49/02/04"))
 ? DToS(CToD("1999/30/04"))
 ? DToS(CToD("30/04/1999"))
 ? DToS(CToD("030/004/99"))
 ? DToS(CToD("123/123/99"))
 ? __SetCentury(.T.),Set(4),DToC(SToD("19990430"))
 ? __SetCentury(.F.),Set(4),DToC(SToD("19990430"))
 FOR i:=1 TO 151
  old:=Set(4,mask)
 NEXT
 ? old,Set(4)
RETURN NIL

FUNCTION Main()
 LOCAL mask:="yyyy-mm-dd",old
 ? Set(4,"yyyy-mm-dd"),Set(4),__SetCentury()
 old:=Set(4,mask)
 ? old,Set(4)
 ? 0d20040229,0d00000000,DToS(CToD("2004-02-29")),DToS(CToD("04/02/29"))
 SET CENTURY OFF
 ? Set(4),0d20040229
 SET CENTURY ON
 ? Set(4),0d20040229
 ? Set(4,"yy-mm-dd"),Set(4),0d20040229,__SetCentury()
 SET CENTURY ON
 ? Set(4),0d20040229
 ? Set(4,"yyy-mm-dd"),Set(4),0d20040229
 ? DToS(CToD("2004-02-29")),DToS(CToD("04/02/29"))
RETURN NIL

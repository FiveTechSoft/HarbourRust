FUNCTION Main()
 LOCAL d:=SToD("19990430")
 ? __SetCentury(),DToC(d)
 SET CENTURY ON
 ? __SetCentury(),DToC(d)
 ? __SetCentury(.F.),DToC(d)
 SET DATE TO ANSI
 ? __SetCentury(),DToC(d)
 ? __SetCentury("ON"),DToC(d)
RETURN NIL

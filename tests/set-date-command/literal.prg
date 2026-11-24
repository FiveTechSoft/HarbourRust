// Own MIT command syntax. Behaviour specification: fresh Harbour.
FUNCTION Main()
 LOCAL d:=SToD("20010203")
 SET DATE FORMAT TO "dd/mm/yyyy"
 ? Set(4),DToC(d),DToS(CToD("04/05/2006")),__SetCentury()
 SET DATE FORMAT "MM-DD-YY"
 ? Set(4),DToC(d),DToS(CToD("05-04-06")),__SetCentury()
 SET CENTURY ON
 ? Set(4),DToC(d)
 SET DATE BRITISH
 ? Set(4),DToC(d)
 SET DATE FORMAT TO ("yyyy/mm/dd")
 ? Set(4),DToC(SToD("")),DToC(d)
RETURN NIL

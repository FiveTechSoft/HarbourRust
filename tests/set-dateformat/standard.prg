FUNCTION Main()
 ? Set(4)
 SET DATE TO BRITISH
 ? Set(4),__SetCentury()
 SET CENTURY ON
 ? Set(4),__SetCentury()
 SET DATE TO ANSI
 ? Set(4),__SetCentury()
 ? Set(4,"mM/dD/yY"),Set(4),__SetCentury()
 SET CENTURY OFF
 ? Set(4),__SetCentury()
 SET CENTURY OFF
 ? Set(4),__SetCentury()
RETURN NIL

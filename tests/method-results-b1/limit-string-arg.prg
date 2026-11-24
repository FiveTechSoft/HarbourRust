#include "hbclass.ch"
CLASS North
 DATA n INIT 12
 METHOD Pick(x)
ENDCLASS
METHOD Pick(x) CLASS North
 IF x<0
  Break("expected")
 ENDIF
 IF x==1
  RETURN Self
 ENDIF
 IF x==2
  RETURN "text"+Str(x,2)
 ENDIF
 IF x==3
  RETURN 1.25
 ENDIF
 IF x==4
  RETURN CToD("2026/11/23")
 ENDIF
RETURN .T.
CLASS South
 DATA n INIT 24
 METHOD Pick(x)
ENDCLASS
METHOD Pick(x) CLASS South
RETURN x*2
FUNCTION Observe(o,x)
 LOCAL a:=o:Pick(x), b:=a
RETURN ValType(b)
FUNCTION Main()
 LOCAL a:=North():New(), b:=South():New()
 ? Observe(a,"bad"), Observe(a,1), Observe(a,2), Observe(a,3), Observe(a,4), Observe(b,5)
RETURN NIL

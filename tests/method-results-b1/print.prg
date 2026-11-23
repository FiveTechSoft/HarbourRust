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
FUNCTION Show(o,x)
 LOCAL a:=o:Pick(x)
 ? a,o:Pick(x),a
RETURN NIL
FUNCTION Main()
 LOCAL o:=North():New(), b
 Show(o,1)
 Show(o,2)
 Show(o,3)
 Show(o,4)
 Show(o,0)
RETURN NIL

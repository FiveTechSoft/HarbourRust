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
CLASS Child FROM North
ENDCLASS
CLASS Override FROM North
 METHOD Pick(x)
ENDCLASS
METHOD Pick(x) CLASS Override
RETURN "override"
FUNCTION Observe(o,x)
 LOCAL a:=o:Pick(x)
RETURN a
FUNCTION Main()
 LOCAL a:=Observe(Child():New(),2),b:=Observe(Override():New(),1),c:=Observe(South():New(),5)
 ? a,b,c
RETURN NIL

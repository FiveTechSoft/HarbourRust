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
FUNCTION FetchResult(o)
 LOCAL a:=o:Pick(1), b:=a
 o:Pick(1)
 RETURN b
FUNCTION Main()
 LOCAL o:=North():New(), x:=FetchResult(o), p:=North():New()
 o:n:=99
 ? o:n,p:n,ValType(x)
RETURN NIL

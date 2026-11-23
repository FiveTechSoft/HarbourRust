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
  RETURN South():New()
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
FUNCTION FetchResult(o,x)
 LOCAL a:=o:Pick(x),b:=a
RETURN b
FUNCTION Main()
 LOCAL a:=North():New(),x,i
 FOR i:=1 TO 503
  x:=FetchResult(a,1)
  FetchResult(a,1)
 NEXT
 ? ValType(x)
RETURN NIL

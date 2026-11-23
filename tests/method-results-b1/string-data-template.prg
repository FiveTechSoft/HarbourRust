#include "hbclass.ch"
CLASS North
 DATA n INIT "init"
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
 DATA n INIT "other"
 METHOD Pick(x)
ENDCLASS
METHOD Pick(x) CLASS South
RETURN x*2
FUNCTION FetchResult(o,x)
 LOCAL a:=o:Pick(x)
RETURN ValType(a)
FUNCTION Main()
 LOCAL o:=North():New(),p:=South():New()
 ? o:n,p:n,FetchResult(o,1),FetchResult(p,2)
 o:n:="changed"
 ? o:n,FetchResult(o,2)
RETURN NIL

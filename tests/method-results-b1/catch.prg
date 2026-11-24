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
FUNCTION Throw(o,x)
 LOCAL a:=o:Pick(x), b:=a
 Break(b)
RETURN NIL
FUNCTION Work(o)
 LOCAL e, b
 BEGIN SEQUENCE
  Throw(o,1)
 RECOVER USING e
  b:=e
  ? ValType(e), ValType(b)
 END SEQUENCE
 BEGIN SEQUENCE
  Throw(o,2)
 RECOVER USING e
  ? e
 END SEQUENCE
RETURN NIL
FUNCTION Main()
 Work(North():New())
RETURN NIL

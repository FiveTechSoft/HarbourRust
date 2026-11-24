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
FUNCTION Show(o)
 LOCAL a:=o:Pick(1), e
 BEGIN SEQUENCE
  ? a,o:Pick(1),o:Pick(-1)
 RECOVER USING e
  ? e
 END SEQUENCE
RETURN NIL
FUNCTION Main()
 LOCAL o:=North():New(), i
 FOR i:=1 TO 5
  Show(o)
 NEXT
RETURN NIL

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
FUNCTION Echo(o,x)
 LOCAL a:=o:Pick(x), b:=a
 a:=o:Pick(2)
RETURN b
FUNCTION Seen(o,x)
 LOCAL a:=Echo(o,x), b:=a
 ? ValType(a), ValType(b)
RETURN b
FUNCTION Work(n)
 LOCAL o:=North():New(), p:=South():New(), i, a
 FOR i:=1 TO n
  a:=Echo(o,Bad())
  Echo(o,Bad())
  Echo(North():New(),1)
  a:=Echo(p,3)
  a:=Echo(o,3)
 NEXT
RETURN NIL
FUNCTION Main()
 LOCAL b, x
 Work(3)
 Work(503)
 x:=Seen(North():New(),1)
 ? ValType(x)
RETURN NIL

FUNCTION Bad()
Break("bad")
RETURN 1

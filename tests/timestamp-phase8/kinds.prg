#include "hbclass.ch"
CLASS Entry
 DATA stamp
 METHOD Put(x)
ENDCLASS
METHOD Put(x) CLASS Entry
 LOCAL k:=ValType(x)
 ::stamp:=x
RETURN Self
FUNCTION Value(n)
 IF n==1
 RETURN "owned"+Str(n,3)
 ENDIF
 IF n==2
 RETURN hb_SToT("20261123")
 ENDIF
RETURN 7
FUNCTION Main()
 LOCAL o:=Entry():New(),t:=hb_SToT("20261123"),i
 FOR i:=1 TO 101
  o:Put(Value(1))
 NEXT
 ? ValType(o:stamp),o:stamp
 o:Put(Value(2))
 ? ValType(o:stamp),hb_TToS(o:stamp)
 o:Put(Value(3))
 ? ValType(o:stamp),o:stamp
RETURN NIL

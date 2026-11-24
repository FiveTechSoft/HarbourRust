#include "hbclass.ch"
CLASS Store
 DATA items
 METHOD New(a)
 METHOD Size()
 METHOD Values()
ENDCLASS
METHOD New(a) CLASS Store
 ::items:=a
RETURN Self
METHOD Size() CLASS Store
RETURN Len(::items)
METHOD Values() CLASS Store
RETURN ::items
CLASS Producer
 DATA count INIT 4
 METHOD Make(fail)
 METHOD Wrap(fail)
ENDCLASS
METHOD Make(fail) CLASS Producer
 LOCAL a:={},i
 FOR i:=1 TO ::count
  AAdd(a,"r"+Str(i,1))
  IF fail .AND. i==3
   Break("stop")
  ENDIF
 NEXT
RETURN a
METHOD Wrap(fail) CLASS Producer
RETURN Store():New(::Make(fail))
CLASS ScalarBox
 DATA value INIT "x"
 METHOD Grow()
 METHOD Compare()
ENDCLASS
METHOD Grow() CLASS ScalarBox
 ::value:=::value+"y"
RETURN ::value
METHOD Compare() CLASS ScalarBox
RETURN ::value=="xyy"
FUNCTION Main()
 LOCAL f:=Producer():New(),o:=ScalarBox():New()
 ? o:Grow(),o:Grow(),o:Compare()
RETURN NIL

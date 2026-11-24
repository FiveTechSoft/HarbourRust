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
FUNCTION FailValue()
 Break("boom")
RETURN 1
FUNCTION Consume(o,a,x)
 ? o:Size(),Len(a),x+1
RETURN NIL
FUNCTION ConsumeDyn(a,x)
 ? Len(a),x+1
RETURN NIL
FUNCTION WorkLoops(n)
 LOCAL f:=Producer():New(),s:=f:Wrap(.F.),i,e,a:=s:Values()
 FOR i:=1 TO n
  BEGIN SEQUENCE
   Consume(Store():New(a),a,FailValue())
  RECOVER USING e
  END SEQUENCE
  BEGIN SEQUENCE
   ConsumeDyn(f:Make(.F.),FailValue())
  RECOVER USING e
  END SEQUENCE
 NEXT
 ? s:Size(),Len(a)
RETURN NIL
FUNCTION Main()
 WorkLoops(517)
RETURN NIL

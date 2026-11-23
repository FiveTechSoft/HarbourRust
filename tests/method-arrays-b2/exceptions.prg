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
FUNCTION Boom()
 Break("boom")
RETURN .F.
FUNCTION WorkLoops(n)
 LOCAL f:=Producer():New(),s:=f:Wrap(.F.),i,e,k:=0
 FOR i:=1 TO n
  s:=f:Wrap(.F.)
  BEGIN SEQUENCE
   s:=f:Wrap(.T.)
  RECOVER USING e
   k++
  END SEQUENCE
  BEGIN SEQUENCE
   f:Wrap(Boom())
  RECOVER USING e
   k++
  END SEQUENCE
 NEXT
 ? k,s:Size()
RETURN NIL
FUNCTION Main()
 WorkLoops(103)
RETURN NIL

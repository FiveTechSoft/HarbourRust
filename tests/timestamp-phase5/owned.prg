FUNCTION MakeValue(x)
 IF x
 RETURN hb_SToT("")
 ENDIF
RETURN " "+Chr(9)
FUNCTION Main()
 LOCAL i,n:=0,t:=hb_SToT("20261123")
 FOR i:=1 TO 517
  IF Empty(MakeValue(.F.))
   n++
  ENDIF
  IF Empty(MakeValue(.T.))
   n++
  ENDIF
 NEXT
 ? n
RETURN NIL

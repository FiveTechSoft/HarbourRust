FUNCTION CopyValue(x)
RETURN x
FUNCTION Describe(x)
RETURN ValType(x)+hb_DToC(x,"YYYY-MM-DD")
FUNCTION Main()
 LOCAL d:=SToD("20261123"),t:=hb_SToT("20261123"),i,s:="",x
 FOR i:=1 TO 101
  s:=Describe(CopyValue(d))
 NEXT
 x:=t
 ? s,Empty(CopyValue(SToD(""))),Empty(CopyValue(d)),ValType(x)
RETURN NIL

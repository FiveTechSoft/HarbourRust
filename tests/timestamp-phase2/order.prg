FUNCTION Form(x)
RETURN hb_TToC(x,"YYYY-MM-DD","HH:MM:SS.fff")
FUNCTION DateForm(x)
RETURN hb_DToC(x,"DD/MM/YY")
FUNCTION Main()
 LOCAL i,t:=hb_SToT("20261123101530987"),s:=""
 FOR i:=1 TO 101
  s:=Form(t)+DateForm(t)+hb_TToC(hb_DToT(SToD("20261123")))
 NEXT
 ? s,Len(s)
RETURN NIL

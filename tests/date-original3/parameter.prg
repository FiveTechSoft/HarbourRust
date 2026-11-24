FUNCTION Prev(d)
RETURN d-DoW(d)+2
FUNCTION Main()
 LOCAL d
 Set(_SET_DATEFORMAT,"dd/mm/yyyy")
 d:=hb_SToD("20240229")
 ? Prev(d),DToS(hb_SToD()),DToS(SToD())
RETURN NIL

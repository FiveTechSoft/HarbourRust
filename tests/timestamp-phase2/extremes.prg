FUNCTION Main()
 LOCAL a:=hb_SToT("00000101000000000"),b:=hb_SToT("99991231235959999")
 ? hb_TToC(a,"YYYY-MM-DD","HH:MM:SS.fff"),hb_TToC(b,"YYYY-MM-DD","HH:MM:SS.fff")
 ? hb_DToC(a,"YYMMDD"),hb_DToC(b,"DDMMYYYY")
 ? hb_TToC(hb_SToT("00000000235959999"),"","SS:MM:HH.fff")
 ? "["+hb_TToC(a,"","")+"]","["+hb_DToC(a,"")+"]"
RETURN NIL

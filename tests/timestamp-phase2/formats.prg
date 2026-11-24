FUNCTION Main()
 LOCAL t:=hb_SToT("20261123101530987"),d:=SToD("20261123")
 ? hb_TToC(t,"YYYY-MM-DD","HH:MM:SS"),hb_TToC(t)
 ? hb_TToC(t,"DD/MM/YY","hh:mm"),hb_TToC(t,"yyyy.mm.dd","hh:mm:ss.fff")
 ? hb_DToC(d,"YYYY-MM-DD"),hb_DToC(d,"DD/MM/YY"),"["+hb_DToC(SToD(""),"YYYY-MM-DD")+"]"
 ? "["+hb_TToC(hb_SToT(""),"YYYY-MM-DD","HH:MM:SS")+"]"
 ? hb_TToC(hb_SToT("00000000101530"),"YYYY-MM-DD","HH:MM:SS")
 ? hb_TToC(d),hb_DToC(d),hb_DToC(t)
 ? "["+hb_TToC(t,"")+ "]","["+hb_TToC(t,"","")+ "]"
RETURN NIL

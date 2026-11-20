FUNCTION Main()
 LOCAL h:=FCreate("edge"),s:="12345",empty:=""
 FWrite(h,"abc"+Chr(0)+"XYZ")
 FClose(h)
 h:=FOpen("edge")
 ? FRead(h,@s,0),s
 ? FRead(h,@s,2),s
 ? FRead(h,@s,5),Len(s),Asc(SubStr(s,2,1)),Right(s,3)
 ? FRead(h,@empty,1),Len(empty)
 ? FRead(h,@s,1),s
 FClose(h)
RETURN NIL

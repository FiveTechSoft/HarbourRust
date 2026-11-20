FUNCTION Main()
 LOCAL h:=FCreate("copy.dat"),s:=Upper("12345"),i
 FWrite(h,"abc")
 FClose(h)
 h:=FOpen("copy.dat")
 ? FRead(h,@s,5),s
 ? FRead(h,@s,1),s
 ? FRead(h,@s,4),s
 ? FRead(h,@s,1),s
 FClose(h)
 FOR i:=1 TO 3
  ? FRead(-1,@s,5),s
 NEXT
RETURN NIL

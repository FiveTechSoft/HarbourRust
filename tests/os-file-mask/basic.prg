PROCEDURE Main()
 LOCAL s:="",i:=0
 FOR i:=1 TO 101
  s:=hb_osFileMask()
  ? "["+s+"]",Len(s),ValType(s),hb_osFileMask(),Upper(hb_osFileMask())
 NEXT
 ? Fetch()
RETURN
FUNCTION Fetch()
RETURN "path/"+hb_osFileMask()

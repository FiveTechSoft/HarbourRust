PROCEDURE Main()
 LOCAL s:=Lower("FILE"),i:=0
 FOR i:=1 TO 101
  ? hb_FileExists(s),hb_FileExists(Lower("FILE")),hb_DirExists("d"+"ir"),hb_FileExists("file"+Chr(0)+"ignored")
 NEXT
 ? s,Probe("file"),Probe("missing")
RETURN
FUNCTION Probe(s)
RETURN hb_FileExists(s)

PROCEDURE Main()
 LOCAL s:=Lower("DIR/ABC.TXT"),t:="",i:=0
 FOR i:=1 TO 101
 t:=hb_FNameNameExt(s)
 ? t,s,hb_FNameNameExt(Lower("X.TXT")),hb_FNameNameExt("a/"+"z.txt")
 NEXT
 ? Probe("z.txt"),s,hb_FNameNameExt(hb_DirSepAdd("a.txt"))
RETURN
FUNCTION Probe(s)
RETURN hb_FNameNameExt(s)

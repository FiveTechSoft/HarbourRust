PROCEDURE Main()
 LOCAL s:=Lower("DIR/ABC.TXT"),t:="",i:=0
 FOR i:=1 TO 101
 t:=hb_FNameName(s)
 ? t,s,hb_FNameExt(Lower("X.TXT")),hb_FNameDir("a/"+"z.txt")
 NEXT
 ? Probe("z.txt"),s,hb_FNameExt(hb_DirSepAdd("a.txt"))
RETURN
FUNCTION Probe(s)
RETURN hb_FNameExt(s)

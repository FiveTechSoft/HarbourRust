PROCEDURE Main()
 LOCAL s:=Lower("A\B\C"),t:="",i:=0
 FOR i:=1 TO 101
 t:=hb_DirSepToOS(s)
 ? t,s,hb_DirSepToOS(Lower("X\Y")),hb_DirSepToOS("a\"+"b")
 NEXT
 ? Probe("z\t"),s,hb_DirSepToOS(hb_DirSepAdd("a\b"))
RETURN
FUNCTION Probe(s)
RETURN hb_DirSepToOS(s)

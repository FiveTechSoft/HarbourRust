PROCEDURE Main()
 LOCAL s:=Lower("ABC///"),t:="",i:=0
 FOR i:=1 TO 101
 t:=hb_DirSepDel(s)
 ? t,s,hb_DirSepDel(Lower("X///")),hb_DirSepDel("a"+"///")
 NEXT
 ? Probe("z///"),s,hb_DirSepDel(hb_DirSepAdd("a"))
RETURN
FUNCTION Probe(s)
RETURN hb_DirSepDel(s)

PROCEDURE Main()
 LOCAL s:="A"+Chr(0)+"éABABA",n:="",z:=Chr(0)
 ? hb_BRAt("",""),hb_BRAt("",s),hb_BRAt(s,""),hb_BRAt("A",s),hb_BRAt("ABA",s),hb_BRAt(z,s),hb_BRAt("é",s)
RETURN

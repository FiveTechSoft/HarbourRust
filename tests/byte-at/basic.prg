PROCEDURE Main()
 LOCAL s:="A"+Chr(0)+"éABABA",n:="",z:=Chr(0)
 ? hb_BAt("",""),hb_BAt("",s),hb_BAt(s,""),hb_BAt("A",s),hb_BAt("ABA",s),hb_BAt(z,s),hb_BAt("é",s)
RETURN

PROCEDURE Main()
 LOCAL needle:="ABA",hay:="ABABABA"
 ? hb_BAt(needle,hay), hb_BRAt(needle,hay)
 ? hb_BRAt("ABA","ABABA"),hb_BRAt("BA","ABABA")
RETURN

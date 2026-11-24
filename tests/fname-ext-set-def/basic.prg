PROCEDURE Main()
 LOCAL s:="",e:=""
 s:=""
 e:=""
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="..x"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="/z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="\z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=Chr(0)+".z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".a"+Chr(0)+"b"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 s:="a"
 e:=""
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="..x"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="/z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="\z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=Chr(0)+".z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".a"+Chr(0)+"b"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 s:="a.b"
 e:=""
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="..x"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="/z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="\z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=Chr(0)+".z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".a"+Chr(0)+"b"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 s:=".x"
 e:=""
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="..x"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="/z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="\z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=Chr(0)+".z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".a"+Chr(0)+"b"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 s:="a/"
 e:=""
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="..x"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="/z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="\z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=Chr(0)+".z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".a"+Chr(0)+"b"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 s:="a/.x"
 e:=""
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="..x"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="/z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="\z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=Chr(0)+".z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".a"+Chr(0)+"b"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 s:="a.b/c.d"
 e:=""
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="..x"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="/z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="\z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=Chr(0)+".z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".a"+Chr(0)+"b"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 s:=".."
 e:=""
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="..x"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="/z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="\z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=Chr(0)+".z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".a"+Chr(0)+"b"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 s:="a\b.c"
 e:=""
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="..x"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="/z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="\z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=Chr(0)+".z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".a"+Chr(0)+"b"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 s:="a"+Chr(0)+".x"
 e:=""
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".txt"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="..x"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="/z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:="\z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=Chr(0)+".z"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
 e:=".a"+Chr(0)+"b"
 ? hb_StrToHex(hb_FNameExtSetDef(s,e))
RETURN

FUNCTION Name(n)
 n++
 ? "name",n
RETURN "abc.ext"
FUNCTION Dir(n)
 n++
 ? "dir",n
RETURN "path"
FUNCTION Main()
 LOCAL n:=0
 ? hb_libName(Name(@n),Dir(@n)),n
 ? hb_libName(NIL,Dir(@n)),n
 ? hb_libName("café/niño"),hb_libName("日本","dir")
RETURN NIL

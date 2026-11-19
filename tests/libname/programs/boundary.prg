FUNCTION Main()
 ? ">"+hb_libName(" name ")+"<"
 ? ">"+hb_libName("a"+Chr(0)+"b.ext")+"<"
 ? ">"+hb_libName("x","a"+Chr(0)+"b")+"<"
 ? ">"+hb_libName("x","a//")+"<"
 ? ">"+hb_libName("x","a\\")+"<"
 ? ">"+hb_libName(".")+"<", ">"+hb_libName("./")+"<"
 ? ">"+hb_libName("name"," ")+"<"
RETURN NIL

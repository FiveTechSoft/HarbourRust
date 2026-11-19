FUNCTION Main()
 ? "nil", ">"+hb_libName(NIL)+"<"
 ? "empty", ">"+hb_libName("")+"<"
 ? "name", hb_libName("name"), hb_libName("libname"), hb_libName("libname.so"), hb_libName("name.so.1")
 ? "path", hb_libName("./dir/name.ext"), hb_libName("/dir/name.ext"), hb_libName("a\\name.ext")
 ? "dots", hb_libName(".name"), hb_libName("name."), hb_libName("a.b.c"), hb_libName(".."), hb_libName("/")
 ? "dir", hb_libName("/old/name.ext","new"), hb_libName("name",""), hb_libName("name","/"), hb_libName("name","a/b/")
 ? "ps", hb_ps()
RETURN NIL

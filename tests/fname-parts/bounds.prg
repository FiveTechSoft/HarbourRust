PROCEDURE Main()
 LOCAL s:=""
 s:=Replicate("a",255)+".txt"
 ? Len(hb_FNameName(s)),hb_FNameExt(s),Len(hb_FNameDir(s))
 s:=Replicate("a",259)+".txt"
 ? Len(hb_FNameName(s)),hb_FNameExt(s),Len(hb_FNameDir(s))
 s:=Replicate("a",260)+".txt"
 ? Len(hb_FNameName(s)),hb_FNameExt(s),Len(hb_FNameDir(s))
 s:=Replicate("a",261)+".txt"
 ? Len(hb_FNameName(s)),hb_FNameExt(s),Len(hb_FNameDir(s))
 s:=Replicate("a",262)+".txt"
 ? Len(hb_FNameName(s)),hb_FNameExt(s),Len(hb_FNameDir(s))
 s:=Replicate("a",263)+".txt"
 ? Len(hb_FNameName(s)),hb_FNameExt(s),Len(hb_FNameDir(s))
 s:=Replicate("a",264)+".txt"
 ? Len(hb_FNameName(s)),hb_FNameExt(s),Len(hb_FNameDir(s))
 s:=Replicate("a",511)+".txt"
 ? Len(hb_FNameName(s)),hb_FNameExt(s),Len(hb_FNameDir(s))
 s:=Replicate("a",4096)+".txt"
 ? Len(hb_FNameName(s)),hb_FNameExt(s),Len(hb_FNameDir(s))
RETURN

PROCEDURE Main()
 LOCAL s:=""
 s:=Replicate("a",255)+"/b.txt"
 ? Len(hb_FNameNameExt(s)),Len(hb_FNameNameExt(Replicate("a",255)+".txt"))
 s:=Replicate("a",259)+"/b.txt"
 ? Len(hb_FNameNameExt(s)),Len(hb_FNameNameExt(Replicate("a",259)+".txt"))
 s:=Replicate("a",260)+"/b.txt"
 ? Len(hb_FNameNameExt(s)),Len(hb_FNameNameExt(Replicate("a",260)+".txt"))
 s:=Replicate("a",261)+"/b.txt"
 ? Len(hb_FNameNameExt(s)),Len(hb_FNameNameExt(Replicate("a",261)+".txt"))
 s:=Replicate("a",262)+"/b.txt"
 ? Len(hb_FNameNameExt(s)),Len(hb_FNameNameExt(Replicate("a",262)+".txt"))
 s:=Replicate("a",263)+"/b.txt"
 ? Len(hb_FNameNameExt(s)),Len(hb_FNameNameExt(Replicate("a",263)+".txt"))
 s:=Replicate("a",264)+"/b.txt"
 ? Len(hb_FNameNameExt(s)),Len(hb_FNameNameExt(Replicate("a",264)+".txt"))
 s:=Replicate("a",511)+"/b.txt"
 ? Len(hb_FNameNameExt(s)),Len(hb_FNameNameExt(Replicate("a",511)+".txt"))
 s:=Replicate("a",4096)+"/b.txt"
 ? Len(hb_FNameNameExt(s)),Len(hb_FNameNameExt(Replicate("a",4096)+".txt"))
RETURN

PROCEDURE Main()
 LOCAL s:=""
 s:=Replicate("d",259)+"/a.b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("a",259)+".b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:="x/"+Replicate("a",259)+".b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("d",260)+"/a.b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("a",260)+".b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:="x/"+Replicate("a",260)+".b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("d",261)+"/a.b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("a",261)+".b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:="x/"+Replicate("a",261)+".b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("d",262)+"/a.b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("a",262)+".b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:="x/"+Replicate("a",262)+".b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("d",263)+"/a.b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("a",263)+".b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:="x/"+Replicate("a",263)+".b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("d",264)+"/a.b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("a",264)+".b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:="x/"+Replicate("a",264)+".b"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:="á/niño.tar.gz"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:="路径/档案.ext"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:="a/"+Chr(0)+".txt"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("a",262)+Chr(0)+"/z.txt"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:=Replicate("a",264)+Chr(0)+"/z.txt"
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
 s:="/"+Replicate("/",270)
 ? Len(hb_FNameNameExt(s)),hb_StrToHex(hb_FNameNameExt(s))
RETURN

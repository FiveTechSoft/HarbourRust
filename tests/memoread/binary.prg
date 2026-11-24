FUNCTION mr_read(p)
RETURN hb_MemoRead(p)
PROCEDURE Main()
 LOCAL c:=hb_MemoRead("@ROOT@/fixture.bin")
 LOCAL p:=AllTrim(" @ROOT@/fixture.bin ")
 LOCAL h:=FOpen("@ROOT@/missing")
 LOCAL i:=0
 ? Len(c),hb_StrToHex(Left(c,7)),Asc(Right(c,1)),FError()
 ? Len(hb_MemoRead(p)),Len(mr_read("@ROOT@/fixture.bin")),Len(p),FError()
 ? Len(hb_MemoRead("@ROOT@/missing")),Len(hb_MemoRead("@ROOT@/empty.bin")),FError()
 FOR i:=1 TO 137
  c:=hb_MemoRead("@ROOT@/fixture.bin")
 NEXT
 ? Len(c),hb_StrToHex(Left(c,7)),FError()
RETURN

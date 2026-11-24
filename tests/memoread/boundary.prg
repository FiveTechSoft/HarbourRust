PROCEDURE Main()
 LOCAL c:=hb_MemoRead("@ROOT@/boundary.bin")
 ? Len(c),Asc(Left(c,1)),Asc(Right(c,1))
 ? Len(hb_MemoRead("@ROOT@"))
 ? Len(hb_MemoRead(AllTrim(" @ROOT@/fixture.bin ")))
RETURN

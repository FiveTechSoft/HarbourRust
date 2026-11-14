procedure Main()
Work()
return
function Work()
local c:=Replicate("01/05/1999",1)
? CToD(c)=CToD("01/05/1999")
? CToD(AllTrim(" 01/05/1999 "))=CToD(c)
? CToD(Change(@c))=CToD("02/06/2001")
? CToD(c)=CToD("02/06/2001")
return nil
function Change(c)
c:=Replicate("02/06/2001",1)
return AllTrim(c)

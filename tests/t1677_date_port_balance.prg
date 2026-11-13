PROCEDURE Main()
LOCAL n:=hb_memcheck(), i:=0
FOR i:=1 TO 500
IF CToD(AllTrim(" 1/5/1999 ")) <> CToD("1/5/1999")
? "bad"
ENDIF
Empty(CToD(Replicate(" ",3)))
ValType(CToD("1/5/"+"1999"))
NEXT
? hb_memcheck()=n
RETURN

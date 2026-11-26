STATIC n:=0
PROCEDURE Main()
LOCAL s:=Space(8)
TRY
? "pending",ValType(F(s)+1.25)
CATCH e
? "caught",e,n,s
END
RETURN
FUNCTION F(s)
? s+""
n+=1
Break("boom")
RETURN 1.25

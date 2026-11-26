STATIC n:=0
PROCEDURE Main()
TRY
? "pending",ValType(F())
CATCH e
? "caught",e,n
END
RETURN
FUNCTION F()
n+=1
Break("boom")
RETURN 1.25

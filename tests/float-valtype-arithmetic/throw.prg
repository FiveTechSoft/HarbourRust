STATIC n:=0
PROCEDURE Main()
TRY
? "pending",ValType(F()+G())
CATCH e
? "caught",e,n
END
RETURN
FUNCTION F()
n+=1
Break("boom")
RETURN 1.25
FUNCTION G()
n+=100
? "unreached"
RETURN 2.5

FUNCTION Main()
PRIVATE e := "pre"
TRY
 Break(7)
CATCH e
 ? e
END
RETURN NIL

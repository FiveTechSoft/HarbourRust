FUNCTION Main()
LOCAL e
TRY
 Break("x")
CATCH e
 ? e
END
TRY
 Break(7)
CATCH e
 ? e
END
RETURN NIL

FUNCTION Fail()
 Break("kept")
RETURN Upper("unreachable")
FUNCTION Main()
 TRY
  hb_FLink("origin",Fail())
 CATCH e
  ? e
 END
RETURN NIL

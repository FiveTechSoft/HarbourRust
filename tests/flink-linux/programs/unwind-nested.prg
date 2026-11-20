FUNCTION Fail()
 Break("kept")
RETURN Upper("never")
FUNCTION Work()
 LOCAL caught:=0
 TRY
  TRY
   hb_FLink("origin",Fail())
  CATCH e
   caught++
   ? e
   hb_FLinkSym("origin",Fail())
  END
 CATCH e
  caught++
  ? e
 END
 TRY
  TRY
   hb_MemoWrit("origin",Fail())
  CATCH e
   ? e
   Break("again")
  END
 CATCH e
  caught++
  ? e
 END
 ? caught
RETURN NIL

FUNCTION Main()
 Work()
RETURN NIL

FUNCTION FailType()
 LOCAL a:=NIL
 a:=a/2
RETURN "destination"
FUNCTION FailString()
 Break("boom")
RETURN Upper("unreachable")
FUNCTION Work()
 LOCAL i,caught:=0
 FOR i:=1 TO 1000
  TRY
   hb_FLink("origin",FailString())
  CATCH
   caught++
  END
  TRY
   hb_FLinkSym("origin",FailString())
  CATCH
   caught++
  END
  TRY
   hb_MemoWrit("origin",FailString())
  CATCH
   caught++
  END
  TRY
   hb_FLink("origin",FailType())
  CATCH
   caught++
  END
  TRY
   hb_FLinkSym("origin",FailType())
  CATCH
   caught++
  END
  TRY
   hb_MemoWrit("origin",FailType())
  CATCH
   caught++
  END
 NEXT
 ? caught
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL

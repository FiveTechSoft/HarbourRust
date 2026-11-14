FUNCTION Main()
LOCAL h := {"a" => 1}
LOCAL yes := hb_HHasKey(h,"a")
LOCAL no := hb_HHasKey(h,"z")
? hb_HHasKey(h,"a"),hb_HHasKey(h,"z")
? yes,no,yes==.T.,no==.F.,.NOT.no,yes.AND..NOT.no
IF hb_HHasKey(h,"a")
? "found"
ENDIF
? F(),ValType(yes)
RETURN NIL
FUNCTION F()
LOCAL h := {"a" => 1}
RETURN hb_HHasKey(h,"a")

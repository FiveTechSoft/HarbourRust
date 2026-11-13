function tick(n)
?? n
return n + 0
procedure main()
local n := 0
local a := {0,2}
? 0 = NIL, NIL = 0, 1 == NIL, NIL == 1
? 0 != NIL, NIL != 0, .T. = NIL, NIL != .F.
? tick(3) != NIL, NIL = tick(4)
? n++ != NIL, NIL != n++, n
? a[1] = NIL, NIL != a[2]
? (QOut("prefix"), n) != NIL
IIF(n != NIL, QOut("not NIL"), )
return

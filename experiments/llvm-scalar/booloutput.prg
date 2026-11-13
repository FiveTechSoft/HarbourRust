function flip(b)
? b
return .NOT. b
function side(n)
? n
return n+0 > 0
function main()
local x := 0
local b := .F.
local z := .T.
if z
b := .T.
endif
? b,z,If(b,.F.,.T.)
? (x++,.T.),x,hb_bitTest(1,0),Empty(0)
? flip(.T.),flip(.F.)
? .F. .AND. side(7),.T. .OR. side(8)
? side(1),side(2)
?? .T.
?? .F.
? "end"
? "a  ",.T.,"z  "
? .T.,"  "
return

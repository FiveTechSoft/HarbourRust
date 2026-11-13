function idlog(x)
return x .AND. .T.
function invert(x)
return .NOT. x
function parity(n)
return If(n+0 == 0,.T.,.NOT. parity(n-1))
function even(n)
return If(n+0 == 0,.T.,odd(n-1))
function odd(n)
return If(n+0 == 0,.F.,even(n-1))
function side(n)
? n
return n+0 > 0
function main()
local i := 0
local b := .F.
? If(idlog(.T.),1,0),If(idlog(.F.),1,0),If(invert(.T.),1,0)
? If(invert(idlog(invert(.F.))),1,0)
for i := 0 to 8
b := parity(i)
? If(b,1,0),If(even(i),1,0),If(odd(i),1,0)
next
? If(idlog(.F.) .AND. side(1),1,0)
? If(idlog(.T.) .OR. side(2),1,0)
? If(idlog(.T.) .AND. side(3),1,0)
? If(idlog(.F.) .OR. side(4),1,0)
return

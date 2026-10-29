function side(n)
? n
return n+0 > 0
function main()
local b := .F.
? Min(.F.,.F.),Min(.F.,.T.),Min(.T.,.F.),Min(.T.,.T.)
? Max(.F.,.F.),Max(.F.,.T.),Max(.T.,.F.),Max(.T.,.T.)
b := Min(Max(.T.,.F.),.T.)
? b,Empty(b),.NOT. b
? Min(side(0),side(1))
? Max(side(2),side(0))
? If(Min(.T.,.F.),1,0),If(Max(.T.,.F.),1,0)
return

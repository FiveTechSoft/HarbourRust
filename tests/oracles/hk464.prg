procedure main()
local s := AllTrim(" abc "), n := 0, a := Array(0), b := {1,2}
? Empty(s), Len(s), Empty(a), Empty(b)
? Empty(Side(@n)), n
? Empty(Zero()), Empty(Minus()), Empty(Text())
return
function Side(n)
n++
return n-1
function Zero()
return 0.0
function Minus()
return -0.00001
function Text()
return AllTrim("   ")

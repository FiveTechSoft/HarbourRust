function Build()
local i := 0
local s := &("'a'+'b'")
for i := 1 to 1000
  s := &("'A'+'BC'")
next
return s

function Pick(v)
return v

function Main()
local s := Build()
local n := &("2*3")
if &("3<5")
  ?? s, Pick(&("10")), Eval({|| &("1+2")})
endif
while n > &("4")
  n := n - &("1")
enddo
?? n, ValType(&("NIL")), &("'XY'+'Z'")
return nil

procedure main()
local n := 0, x := 0x7FFFFFFFFFFFFFFF
? hb_bitNot(hb_bitNot(x)), hb_bitAnd(x,-1)
? hb_bitXor(NextValue(@n), NextValue(@n), NextValue(@n)), n
? hb_bitAnd(hb_bitOr(1,2),hb_bitXor(7,4)), hb_bitNot(hb_bitAnd(7,3))
return
function NextValue(n)
n++
return n

procedure main()
local n := 0, x := 7
? hb_bitAnd(7,3), hb_bitOr(1,2,4), hb_bitXor(7,3,1), hb_bitNot(0)
? hb_bitAnd(-1,255), hb_bitOr(-4,1), hb_bitXor(-1,-1)
? hb_bitAnd(Side(@n,7),Side(@n,3),Side(@n,1)), n
? hb_bitNot(x), hb_bitAnd(0x7FFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFE)
? hb_bitNot(-9223372036854775807-1)
? hb_bitOr(10000000000,1), hb_bitOr(x,10000000000)
return
function Side(n,x)
n++
return x+0

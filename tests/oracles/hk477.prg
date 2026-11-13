procedure main()
local n := 0, x := -1
? hb_bitTest(0,0), hb_bitTest(1,0), hb_bitTest(2,0), hb_bitTest(2,1)
? hb_bitTest(x,63), hb_bitTest(0x7FFFFFFFFFFFFFFF,63)
? hb_bitSet(0,0), hb_bitReset(7,1), hb_bitSet(0,1), hb_bitReset(15,0)
? hb_bitSet(Side(@n),3), n, hb_bitTest(Side(@n),1), n
? hb_bitReset(-1,63), hb_bitSet(0,63), hb_bitSet(x,0)
return
function Side(n)
n++
return n

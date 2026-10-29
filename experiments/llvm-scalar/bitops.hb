function mark(n)
? n
return n+0
function main()
local x := 0
local low := -9223372036854775807
local b := .F.
low -= 1
? hb_bitAnd(7,3),hb_bitOr(1,2,4),hb_bitXor(7,3,1),hb_bitNot(0)
? hb_bitAnd(-1,255),hb_bitOr(-4,1),hb_bitXor(-1,-1),hb_bitNot(low)
? hb_bitAnd(++x,++x,++x),x
? hb_bitOr(mark(1),mark(2),mark(4))
? hb_bitNot(hb_bitNot(low)), hb_bitAnd(hb_bitOr(1,2),hb_bitXor(7,4))
? hb_bitSet(0,63),hb_bitReset(-1,63),hb_bitSet(-1,0)
? hb_bitSet(0,0),hb_bitReset(7,1)
b := hb_bitTest(low,63)
? If(b,1,0),If(.NOT. hb_bitTest(1,63),1,0)
? If(hb_bitTest(0,0) .AND. (++x>0),1,0),x
? If(hb_bitTest(1,0) .OR. (++x>0),1,0),x
? hb_bitSet((x++,x),3),x
return

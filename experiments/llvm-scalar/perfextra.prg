// Performance probes using only already accepted I64/control-flow constructs.
function bitmix(n)
local i := 0
local x := 1
for i := 1 to n
x := hb_bitXor(hb_bitOr(x*3,i),hb_bitAnd(x,255))
next
return x
function minmaxloop(n)
local i := 0
local x := n+0
for i := 1 to n
x := Max(Min(x+i,1000003),i-3)
next
return x+i
function mixstep(x,i)
return hb_bitXor(x*3+i,i-7)
function callloop(n)
local i := 0
local x := 1
for i := 1 to n
x := mixstep(x,i)
next
return x
function reverse(n)
local i := 0
local x := 0
for i := n to 1 step -1
x := x*3+i
next
return x+i
function whileflow(n)
local i := 0
local x := 1
while i < n
 i += 1
 if hb_bitAnd(i,7) == 0
 loop
 endif
 x := x*3+i
 if x == 0
 exit
 endif
enddo
return x+i
function main()
? bitmix(100),minmaxloop(100),callloop(100),reverse(100),whileflow(100)
return

function main()
local x := 1
local a := {0,0,0}
? (x)++, x, ++(x), x
x := 0
while x++ < 4
if x = 2
loop
endif
if x = 4
exit
endif
a[x] := x++
enddo
? x, a[1], a[2], a[3]
? IIF(.F., ++x, x++), x
return

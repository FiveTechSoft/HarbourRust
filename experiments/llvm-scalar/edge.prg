function choose(n)
return If(n < 0, 7, n * n)
function main()
local i := 0
local s := 0
for i := 3 to -3 step -2
s += i
next
? s, i, choose(-2), choose(9)
for i := 9223372036854775806 to 9223372036854775807
s := 1
next
? i, s
local low := -9223372036854775807
low -= 1
for i := -9223372036854775807 to low step -1
s := 2
next
? i, s
while s < 6
s += 1
enddo
? s
return

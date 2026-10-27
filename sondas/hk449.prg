function fact(n)
return If(n < 2, 1, n * fact(n-1))
function main()
local i := 0
local s := 0
for i := 1 to 100000
s += fact(10)
next
? s, i
return

function bump(x)
local old := x++
return old + ++x
function update(x)
return x--
function main()
local n := 3
? bump(n), n
? update(@n), n
? -n++, n
? 2 * n++, n
? n++ ^ 2, n
return

function deep(n)
local v := 9223372036854775807
return ++v+n
function middle(n)
return deep(n)+1
function main()
? middle(3)
return

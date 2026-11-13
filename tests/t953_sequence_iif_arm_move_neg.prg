function take(s)
return Asc(s)
function main()
local s := AllTrim(" abc ")
? IIF(.T., (take(s), 1), 1) + Len(s)
return

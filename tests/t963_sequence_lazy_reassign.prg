function take(s)
return Asc(s)
function main()
local s := AllTrim(" abc ")
local t := AllTrim(" xyz ")
local x := 0
? IIF(.T., (take(s), ++x), 2), x
? IIF(.F., 2, (take(t), ++x)), x
s := AllTrim(" reset ")
t := AllTrim(" again ")
? s, t
? .F. .AND. (x++, .T.), x
? .T. .OR. (x++, .F.), x
return

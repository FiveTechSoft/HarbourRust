PROCEDURE MAIN()
local s := "abcdef"
local r := ""
r := Transform(s, Change(@s))
? r
RETURN
FUNCTION Change(s)
s := "zz"
RETURN "@!"

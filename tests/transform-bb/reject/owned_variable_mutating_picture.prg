PROCEDURE MAIN()
local s := Upper("abcdef")
local r := ""
r := Transform(s, Change(@s))
? r
RETURN
FUNCTION Change(s)
s := "zz" + "y"
RETURN "@!"

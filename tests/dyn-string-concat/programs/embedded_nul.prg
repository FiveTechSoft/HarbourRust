function main()
local d,s := "",t := ""
d := Chr(0)+"tail"
s := "a"+d
t := d+"z"
? Len(s), Len(t), Asc(SubStr(s,2,1)), Asc(SubStr(t,1,1))
d := ""
? "a"+d, d+"b"
return nil

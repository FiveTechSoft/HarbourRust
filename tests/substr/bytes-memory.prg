procedure Main()
Work()
? hb_memcheck()
return
function Work()
local s := "A"+Chr(0)+Chr(255)+"BC"
local a := SubStr(s,2,2)
? Len(s),Len(a),Asc(a),Asc(SubStr(a,2,1))
? Asc(SubStr(s,-2,1)),Asc(SubStr(s,-1,1)),Len(SubStr("",0,99))
? Len(SubStr("áé",2,1)), Asc(SubStr("áé",2,1))
return nil

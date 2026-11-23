function main()
local d := ctod("")
set date german
d := makedate(1991, 5, 19)
? d
d := makedate(2024, 12, 1)
? d
return nil

function makedate(yy, xx, zz)
local cDate, retvar
cDate := str(zz, 2) + "." + str(xx, 2) + "." + str(yy, 4)
retvar := ctod(cDate)
return retvar

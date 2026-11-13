function main()
local a := {}
local i := 0
aadd(a, 3)
aadd(a, 4)
switch a[1]
case 3
i := i + 10
case 4
i := i + 100
endswitch
? i
switch a[2]
case 3
i := i + 1000
otherwise
i := i + 10000
endswitch
? i
return nil

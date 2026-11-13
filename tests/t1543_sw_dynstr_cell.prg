function main()
local x := {1, "canary", 7}
local i := 0
switch x[2]
case "canary"
i := 10
case "zz"
i := 100
otherwise
i := 1000
endswitch
? i
switch x[2]
case 3
i := i + 1
otherwise
i := i + 1
endswitch
? i
switch x[2]
case "canary"
switch x[3]
case 7
exit
endswitch
exit
case "zz"
? "zz"
endswitch
? "after"
return nil

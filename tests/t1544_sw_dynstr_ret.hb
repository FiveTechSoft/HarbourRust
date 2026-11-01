function mkstr()
local x
x := 1
x := "abc"
return x
function mkint()
local y
y := "z"
y := 7
return y
function main()
local i := 0
switch mkstr()
case "abc"
i := 10
case 3
i := 100
otherwise
i := 1000
endswitch
? i
switch mkint()
case 7
i := i + 10000
case "7"
i := i + 100000
endswitch
? i
return nil

function main()
local i := 2
local s := "ab"
switch i
case 1
? "one"
case 2
? "two"
otherwise
? "oth"
endswitch
switch s
case "ab"
? "AB"
case "x"
? "x"
otherwise
? "soth"
endswitch
? "done"
return nil

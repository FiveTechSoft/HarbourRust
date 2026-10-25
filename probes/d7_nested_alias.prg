function main()
local a := {{1, 2}, {3, 4}}
local b := a[1]
b[1] := 99
? a[1][1]
return nil

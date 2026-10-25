// HB-EXACT: {|| 42} - codeblock without parameters (probe c5)
function main()
local b := {|| 42}
? eval(b)
return nil

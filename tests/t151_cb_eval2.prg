// HB-EXACT: two-parameter codeblock (probe c2)
function main()
local b := {|x, y| x + y}
? eval(b, 3, 4)
return nil

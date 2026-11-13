// HB-EXACT: comma-separated body returns the LAST expression (probe c4)
function main()
local b := {|x| x + 1, x + 2}
? eval(b, 5)
return nil

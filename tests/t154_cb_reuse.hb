// HB-EXACT: one block evaluated twice inside an expression (probe c9)
function main()
local b := {|x| x * 10}
? eval(b, 1) + eval(b, 2)
return nil

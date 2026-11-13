// HB-EXACT: eval({|x| x+1}, 5) - codeblock with one parameter (probe c1)
function main()
local b := {|x| x + 1}
? eval(b, 5)
return nil

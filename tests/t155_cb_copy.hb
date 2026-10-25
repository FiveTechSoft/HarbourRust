// HB-EXACT: a codeblock value copies on assignment; eval through the copy (probe c10)
function main()
local b := {|x| x + 1}
local c := b
? eval(c, 7)
return nil

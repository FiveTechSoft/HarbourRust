function applyit(b, x)
  ? eval(b, x)
return eval(b, x + 1)
function main()
  local dup := {|v| v * 2}
  local r := applyit(dup, 21)
  ? r
return NIL

// HB-EXACT: extra eval arguments are EVALUATED (side effects run) and ignored (probes c7/c7b)
function mark()
  ? 42
  return 99
function main()
local b := {|x| x + 1}
? eval(b, 5, mark())
return nil

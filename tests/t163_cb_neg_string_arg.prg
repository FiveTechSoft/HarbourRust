// neg: non-integer eval argument in this increment
function main()
  local b := {|x| x + 1}
  ? eval(b, "hola")
  return nil

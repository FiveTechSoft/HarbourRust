// neg: non-integer codeblock body in this increment
function main()
  local b := {|x| "hola"}
  ? eval(b, 1)
  return nil

// neg: reassigning a block variable with a different arity (block types carry their arity)
function main()
  local b := {|x| x + 1}
  b := {|| 0}
  ? eval(b)
  return nil
